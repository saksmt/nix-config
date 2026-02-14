{
  lib,
  config,
  pkgs,
  ...
}:
let
  targetArch = if config.boot.loader.grub.forcei686 then "ia32" else pkgs.stdenv.hostPlatform.efiArch;

  refindBinary =
    if targetArch == "x64" || targetArch == "aa64" then "refind_${targetArch}.efi" else null;

  # Builds a single menu entry
  menuBuilderGrub2 =
    {
      name,
      class,
      image,
      params,
      initrd,
    }:
    ''
      menuentry '${name}' --class ${class} {
        # Fallback to UEFI console for boot, efifb sometimes has difficulties.
        terminal_output console

        linux ${image} \''${isoboot} ${params}
        initrd ${initrd}
      }
    '';

  getMenuName =
    if builtins.isFunction config.images.iso.boot.entryname then
      config.images.iso.boot.entryname
    else
      _: config.images.iso.boot.entryname;

  # Builds all menu entries
  buildMenuGrub2 =
    {
      cfg ? config,
      params ? [ ],
    }:
    let
      kernelPath = "${config.images.iso.boot.dir}/${cfg.boot.kernelPackages.kernel}/${cfg.system.boot.loader.kernelFile}";
      initrdPath = "${config.images.iso.boot.dir}/${cfg.system.build.initialRamdisk}/${cfg.system.boot.loader.initrdFile}";
      initParam = "init=${cfg.system.build.toplevel}/init";

      thisEntry = menuBuilderGrub2 {
        name = getMenuName cfg;
        params = "${initParam} ${toString cfg.boot.kernelParams} ${toString params}";
        image = kernelPath;
        initrd = initrdPath;
        class = "installer";
      };
      rest = lib.mapAttrsToList (
        specName:
        { configuration, ... }:
        buildMenuGrub2 {
          cfg = configuration;
          inherit params;
        }
      ) cfg.specialisation;
    in
    ''
      ${thisEntry}

      ${lib.concatStringsSep "\n" rest}
    '';

  grubRoot = "${config.images.iso.boot.grub.root-dir}";

  grubMenuCfg =
    let
      theme = config.images.iso.boot.grub.theme;
      setTheme =
        # When there is a theme configured, use it, otherwise use the background image.
        if theme != null then
          ''
            # Sets theme.
            set theme=${grubRoot}/grub-theme/theme.txt
            # Load theme fonts
            $(find ${theme} -iname '*.pf2' -printf "loadfont ${grubRoot}/grub-theme/%P\n")
          ''
        else
          ''
            if background_image ${grubRoot}/background.png; then
              # Black background means transparent background when there
              # is a background image set... This seems undocumented :(
              set color_normal=black/black
              set color_highlight=white/blue
            else
              # Falls back again to proper colors.
              set menu_color_normal=cyan/blue
              set menu_color_highlight=white/blue
            fi
          '';
      textmode = lib.boolToString (config.images.iso.boot.grub.force-text-mode);
    in
    ''
      set textmode=${textmode}

      #
      # Menu configuration
      #

      # Search using fs label
      search --no-floppy --set=root -l ${config.images.iso.volumeID}

      set gfxpayload=keep
      set gfxmode=${config.images.iso.boot.grub.gfx-modes}
      insmod gfxterm
      insmod all_video
      insmod png

      if [ "\$textmode" == "false" ]; then
        terminal_output gfxterm
        terminal_input  console
      else
        terminal_output console
        terminal_input  console
        # Sets colors for console term.
        set menu_color_normal=cyan/blue
        set menu_color_highlight=white/blue
      fi

      ${setTheme}

      hiddenentry 'Text mode' --hotkey 't' {
        loadfont ${grubRoot}/fonts/unicode.pf2
        set textmode=true
        terminal_output console
      }

      ${lib.optionalString (theme != null) ''
        hiddenentry 'GUI mode' --hotkey 'g' {
          $(find ${theme} -iname '*.pf2' -printf "loadfont ${grubRoot}/grub-theme/%P\n")
          set textmode=false
          terminal_output gfxterm
        }
      ''}

      ${config.images.iso.boot.grub.extra-menu-config}
    '';

  mkSubmenu = title: class: content: ''
    submenu "${title}" --class ${class} {
      ${grubMenuCfg}
      ${content}
    }
  '';

  mkGrubCfg =
    pkgs.runCommand "generate-grub.cfg-for-iso"
      {
        nativeBuildInputs = [ pkgs.buildPackages.grub2_efi ];
        strictDeps = true;
      }
      ''
        cat <<EOF > $out

        set timeout=${toString config.images.iso.boot.grub.timeout}

        clear
        # This message will only be viewable on the default (UEFI) console.
        echo ""
        echo "Loading graphical boot menu..."
        echo ""
        echo "Press 't' to use the text boot menu on this console..."
        echo ""


        ${grubMenuCfg}

        ${config.images.iso.boot.grub.extra-initial-config}

        # If the parameter iso_path is set, append the findiso parameter to the kernel
        # line. We need this to allow the nixos iso to be booted from grub directly.
        if [ \''${iso_path} ] ; then
          set isoboot="findiso=\''${iso_path}"
        fi

        #
        # Menu entries
        #

        ${buildMenuGrub2 { }}

        ${mkSubmenu "Options" "submenu" (
          lib.concatMapStringsSep "\n" (
            {
              title,
              class,
              params,
            }:
            mkSubmenu title class (buildMenuGrub2 {
              inherit params;
            })
          ) config.images.iso.boot.grub.extra-menu-entries
        )}

        ${lib.optionalString (config.images.iso.boot.include-refind && refindBinary != null) ''
          # GRUB apparently cannot do "chainloader" operations on "CD".
          if [ "\$root" != "cd0" ]; then
            menuentry 'rEFInd' --class refind {
              chainloader ${grubRoot}/${refindBinary}
            }
          fi
        ''}
        ${lib.optionalString config.images.iso.boot.grub.include-memtest ''
          menuentry 'Memtest86+' --class debug {
            linux ${grubRoot}/memtest.bin ${toString config.boot.loader.grub.memtest86.params}
          }
        ''}
        ${lib.optionalString config.images.iso.boot.grub.include-reboot-to-bios ''
          menuentry 'Firmware Setup' --class settings {
            fwsetup
            clear
            echo ""
            echo "If you see this message, your EFI system doesn't support this feature."
            echo ""
          }
        ''}
        ${lib.optionalString config.images.iso.boot.grub.include-shutdown ''
          menuentry 'Shutdown' --class shutdown {
            halt
          }
        ''}
        ${config.images.iso.boot.grub.extra-trailing-config}

        EOF

        grub-script-check $out
      '';
in
{
  config = {
    # Don't build the GRUB menu builder script, since we don't need it
    # here and it causes a cyclic dependency.
    boot.loader.grub.enable = lib.mkImageMediaOverride false;

    # required since grub-mkrescue produces exactly that (for whatever reason).
    boot.initrd.kernelModules = [ "hfsplus" "nls_utf8" ];
    boot.initrd.extraUtilsCommands = ''
      copy_bin_and_libs ${lib.getBin pkgs.hfsprogs}/bin/fsck.hfsplus
    '';
    system.fsPackages = [ pkgs.hfsprogs ];
    boot.initrd.systemd.initrdBin = [ pkgs.hfsprogs ];

    environment.systemPackages = [
      config.images.iso.boot.grub.package
    ];
    system.extraDependencies = [ config.images.iso.boot.grub.package ];

    images.iso.contents = [
      {
        source = mkGrubCfg;
        target = config.images.iso.boot.grub.root-dir + "/grub.cfg";
      }
    ]
    ++ lib.optionals (config.images.iso.boot.grub.theme != null) [
      {
        source = config.images.iso.boot.grub.theme;
        target = config.images.iso.boot.grub.root-dir + "/grub-theme";
      }
    ]
    ++ lib.optionals (config.images.iso.boot.include-refind && refindBinary != null) [
      {
        source = "${pkgs.refind}/share/refind/${refindBinary}";
        target = config.images.iso.boot.grub.root-dir + "/${refindBinary}";
      }
    ]
    ++ lib.optionals config.images.iso.boot.grub.include-memtest [
      {
        source = pkgs.memtest86plus.efi;
        target = "${config.images.iso.boot.grub.root-dir}/memtest.bin";
      }
    ]
    ++ lib.optionals (config.images.iso.boot.splash-image != null) [
      {
        source = config.images.iso.boot.splash-image;
        target = config.images.iso.boot.grub.root-dir + "/background.png";
      }
    ];
  };
}

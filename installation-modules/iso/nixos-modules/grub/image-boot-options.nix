{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    images.iso.boot.splash-image = lib.mkOption {
      default = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/a9e05d7deb38a8e005a2b52575a3f59a63a4dba0/bootloader/efi-background.png";
        sha256 = "18lfwmp8yq923322nlb9gxrh5qikj1wsk6g5qvdh31c4h5b1538x";
      };
      description = ''
        The splash image to use in the EFI bootloader.
      '';
    };

    images.iso.boot.entryname = lib.mkOption {
      default = config: "NixOS";
      type = lib.types.either lib.types.str (lib.types.functionTo lib.types.str);
    };

    images.iso.boot.grub.theme = lib.mkOption {
      default = pkgs.nixos-grub2-theme;
      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.package);
      description = ''
        The grub2 theme used for UEFI boot.
      '';
    };

    images.iso.boot.grub.preload-modules = lib.mkOption {
      default = [
        # Basic modules for filesystems and partition schemes
        "fat"
        "iso9660"
        "part_gpt"
        "part_msdos"

        # Basic stuff
        "normal"
        "boot"
        "linux"
        "configfile"
        "loopback"
        "chain"
        "halt"

        # Allows rebooting into firmware setup interface
        "efifwsetup"

        # EFI Graphics Output Protocol
        "efi_gop"

        # User commands
        "ls"

        # System commands
        "search"
        "search_label"
        "search_fs_uuid"
        "search_fs_file"
        "echo"

        # We're not using it anymore, but we'll leave it in so it can be used
        # by user, with the console using "C"
        "serial"

        # Graphical mode stuff
        "gfxmenu"
        "gfxterm"
        "gfxterm_background"
        "gfxterm_menu"
        "test"
        "loadenv"
        "all_video"
        "videoinfo"

        # File types for graphical mode
        "png"
      ];
      type = lib.types.listOf lib.types.str;
      description = ''
        List of modules to preload for GRUB.
      '';
    };

    images.iso.boot.grub.force-text-mode = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        Whether to use text mode instead of graphical grub.
        A value of `true` means graphical mode is not tried to be used.

        This is useful for validating that graphics mode usage is not at the root cause of a problem with the iso image.

        If text mode is required off-handedly (e.g. for serial use) you can use the `T` key, after being prompted, to use text mode for the current boot.
      '';
    };

    images.iso.boot.grub.extra-trailing-config = lib.mkOption {
      default = "";
      type = lib.types.lines;
      description = ''
        Extra configuration for GRUB. As in /boot/grub/grub.cfg.
      '';
    };

    images.iso.boot.grub.extra-initial-config = lib.mkOption {
      default = "";
      type = lib.types.lines;
      description = ''
        Extra configuration for GRUB. As in /boot/grub/grub.cfg.
      '';
    };

    images.iso.boot.grub.extra-menu-config = lib.mkOption {
      default = "";
      type = lib.types.lines;
      description = ''
        Extra configuration for GRUB placed in menuentries. As in /boot/grub/grub.cfg.
      '';
    };

    images.iso.boot.grub.extra-menu-entries = lib.mkOption {
      default = [
        {
          title = "Copy ISO Files to RAM";
          class = "copytoram";
          params = [ "copytoram" ];
        }
        {
          title = "No modesetting";
          class = "nomodeset";
          params = [ "nomodeset" ];
        }
        {
          title = "Debug Console Output";
          class = "debug";
          params = [ "debug" ];
        }
        # If we boot into a graphical environment where X is autoran
        # and always crashes, it makes the media unusable. Allow the user
        # to disable this.
        {
          title = "Disable display-manager";
          class = "quirk-disable-displaymanager";
          params = [
            "systemd.mask=display-manager.service"
            "plymouth.enable=0"
          ];
        }
        # DPI scaling for monitors with high DPI
        # set_dpi is a custom env variable handled in bedrock layer of iso
        {
          title = "Set DPI scaling to 125%";
          class = "quirk-hidpi-125";
          params = [
            "livecd.set_dpi=120"
          ];
        }
        {
          title = "Set DPI scaling to 150%";
          class = "quirk-hidpi-150";
          params = [
            "livecd.set_dpi=144"
          ];
        }
        {
          title = "Set DPI scaling to 200%";
          class = "quirk-hidpi-200";
          params = [
            "livecd.set_dpi=192"
          ];
        }
        # Some laptop and convertibles have the panel installed in an
        # inconvenient way, rotated away from the keyboard.
        # Those entries makes it easier to use the installer.
        {
          title = "Rotate framebuffer Clockwise";
          class = "rotate-90cw";
          params = [ "fbcon=rotate:1" ];
        }
        {
          title = "Rotate framebuffer Upside-Down";
          class = "rotate-180";
          params = [ "fbcon=rotate:2" ];
        }
        {
          title = "Rotate framebuffer Counter-Clockwise";
          class = "rotate-90ccw";
          params = [ "fbcon=rotate:3" ];
        }
        # Serial access is a must!
        {
          title = "Serial console=ttyS0,115200n8";
          class = "serial";
          params = [ "console=ttyS0,115200n8" ];
        }
      ];
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            title = lib.mkOption { type = lib.types.str; };
            class = lib.mkOption {
              type = lib.types.str;
              description = "grub submenu entry class";
            };
            params = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = "extra kernel params";
            };
          };
        }
      );
      description = ''
        Extra configuration for GRUB submenus. Added to each nixos entry.
      '';
    };

    images.iso.boot.grub.include-memtest = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Whether to include memtest86+ in the grub menu.
      '';
    };

    images.iso.boot.grub.include-reboot-to-bios = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Whether to include firmware setup/reboot to BIOS option in the grub menu.
      '';
    };

    images.iso.boot.grub.include-shutdown = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Whether to include an option to shutdown in the grub menu.
      '';
    };

    images.iso.boot.grub.timeout = lib.mkOption {
      default = -1;
      type = lib.types.int;
      description = ''
        Timeout for GRUB menu in seconds. 0 means no timeout. -1 means infinite timeout.
      '';
    };

    images.iso.boot.include-refind = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Whether to include rEFInd in the final image (and include it in grub menu).
      '';
    };

    images.iso.boot.grub.gfx-modes = lib.mkOption {
      default = lib.concatStringsSep "," [
        # GRUB will use the first valid mode listed here.
        # `auto` will sometimes choose the smallest valid mode it detects.
        # So instead we'll list a lot of possibly valid modes :/
        #"3840x2160"
        #"2560x1440"
        "1920x1200"
        "1920x1080"
        "1366x768"
        "1280x800"
        "1280x720"
        "1200x1920"
        "1024x768"
        "800x1280"
        "800x600"
        "auto"
      ];
      type = lib.types.commas;
      description = ''
        List of graphics modes to use for GRUB. As in gfx_mode of /boot/grub/grub.cfg.
      '';
    };

    images.iso.boot.grub.package = lib.mkOption {
      default = (if config.boot.loader.grub.forcei686 then pkgs.pkgsi686Linux else pkgs).grub2_efi;
      type = lib.types.package;
      description = ''
        The GRUB package to use for the ISO image.
        DO NOT CHANGE THIS UNLESS YOU KNOW WHAT YOU ARE DOING.
      '';
    };

    images.iso.boot.grub.root-dir = lib.mkOption {
      default = "/boot/grub";
      type = lib.types.path;
      description = ''
        The root directory for GRUB. This is the directory where GRUB will look for its configuration files.
        DO NOT CHANGE THIS UNLESS YOU'VE ALSO FIXED ISO IMAGE GENERATION WHICH RELIES ON grub-mkrescue.
      '';
    };

  };
}

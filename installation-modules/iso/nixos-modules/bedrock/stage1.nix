{ lib,
  config,
  pkgs,
  utils,
  ... }:
{
  config = {
    assertions = [
      (
        let
          badSpecs = lib.filterAttrs (
            specName: specCfg: specCfg.configuration.images.iso.volumeID != config.images.iso.volumeID
          ) config.specialisation;
        in
        {
          assertion = badSpecs == { };
          message = ''
            All specialisations must use the same 'images.iso.volumeID'.

            Specialisations with different volumeIDs:

            ${lib.concatMapStringsSep "\n" (specName: ''
              - ${specName}
            '') (builtins.attrNames badSpecs)}
          '';
        }
      )
    ];

    # In stage 1 of the boot, mount the CD as the root FS by label so
    # that we don't need to know its device.  We pass the label of the
    # root filesystem on the kernel command line, rather than in
    # `fileSystems' below.  This allows CD-to-USB converters such as
    # UNetbootin to rewrite the kernel command line to pass the label or
    # UUID of the USB stick.  It would be nicer to write
    # `root=/dev/disk/by-label/...' here, but UNetbootin doesn't
    # recognise that.
    boot.kernelParams = lib.optionals (!config.boot.initrd.systemd.enable) [
      "boot.shell_on_fail"
      "root=LABEL=${config.images.iso.volumeID}"
    ];

    boot.initrd.availableKernelModules = [
      "squashfs"
      "iso9660"
      "uas"
      "overlay"
    ];

    boot.initrd.kernelModules = [
      "loop"
      "overlay"
    ];

    boot.initrd.systemd = lib.mkIf config.boot.initrd.systemd.enable {
      emergencyAccess = true;

      # Most of util-linux is not included by default.
      initrdBin = [ config.boot.initrd.systemd.package.util-linux ];
      services.copytoram = {
        description = "Copy ISO contents to RAM";
        requiredBy = [ "initrd.target" ];
        before = [
          "${utils.escapeSystemdPath "/sysroot/nix/.ro-store"}.mount"
          "initrd-switch-root.target"
        ];
        unitConfig = {
          RequiresMountsFor = "/sysroot/iso";
          ConditionKernelCommandLine = "copytoram";
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        path = [
          pkgs.coreutils
          config.boot.initrd.systemd.package.util-linux
        ];
        script = ''
          device=$(findmnt -n -o SOURCE --target /sysroot/iso)
          fsSize=$(blockdev --getsize64 "$device" || stat -Lc '%s' "$device")
          mkdir -p /tmp-iso
          mount --bind --make-private /sysroot/iso /tmp-iso
          umount /sysroot/iso
          mount -t tmpfs -o size="$fsSize" tmpfs /sysroot/iso
          cp -r /tmp-iso/* /sysroot/iso/
          umount /tmp-iso
          rm -r /tmp-iso
        '';
      };
    };
  };
}
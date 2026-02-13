{
  lib,
  config,
  pkgs,
  utils,
  ...
}:
{
  # store them in lib so we can mkImageMediaOverride the
  # entire file system layout in installation media (only)
  config.lib.isoFileSystems = {
    "/" = lib.mkImageMediaOverride {
      fsType = "tmpfs";
      options = [ "mode=0755" ];
    };

    # Note that /dev/root is a symlink to the actual root device
    # specified on the kernel command line, created in the stage 1
    # init script.
    "/iso" = lib.mkImageMediaOverride {
      device =
        if config.boot.initrd.systemd.enable then
          "/dev/disk/by-label/${config.images.iso.volumeID}"
        else
          "/dev/root";
      neededForBoot = true;
      noCheck = true;
    };

    # In stage 1, mount a tmpfs on top of /nix/store (the squashfs
    # image) to make this a live CD.
    "/nix/.ro-store" = lib.mkImageMediaOverride {
      fsType = "squashfs";
      device = "${lib.optionalString config.boot.initrd.systemd.enable "/sysroot"}/iso/nix-store.squashfs";
      options = [
        "loop"
      ]
      ++ lib.optional (config.boot.kernelPackages.kernel.kernelAtLeast "6.2") "threads=multi";
      neededForBoot = true;
    };

    "/nix/.rw-store" = lib.mkImageMediaOverride {
      fsType = "tmpfs";
      options = [ "mode=0755" ];
      neededForBoot = true;
    };

    "/nix/store" = lib.mkImageMediaOverride {
      overlay = {
        lowerdir = [ "/nix/.ro-store" ];
        upperdir = "/nix/.rw-store/store";
        workdir = "/nix/.rw-store/work";
      };
    };
  };

  config = {
    fileSystems = config.lib.isoFileSystems;

    # Closures to be copied to the Nix store on the CD, namely the init
    # script and the top-level system configuration directory.
    images.iso.nix-store-contents = [
      config.system.build.toplevel
    ]
    ++ lib.optional config.images.iso.include-system-build-dependencies config.system.build.toplevel.drvPath;

    # Individual files to be included on the CD, outside of the Nix
    # store on the CD.
    images.iso.contents =
      let
        cfgFiles =
          cfg:
          [
            {
              source = cfg.boot.kernelPackages.kernel + "/" + cfg.system.boot.loader.kernelFile;
              target =
                "${config.images.iso.boot.dir}/"
                + cfg.boot.kernelPackages.kernel
                + "/"
                + cfg.system.boot.loader.kernelFile;
            }
            {
              source = cfg.system.build.initialRamdisk + "/" + cfg.system.boot.loader.initrdFile;
              target =
                "${config.images.iso.boot.dir}/"
                + cfg.system.build.initialRamdisk
                + "/"
                + cfg.system.boot.loader.initrdFile;
            }
          ]
          ++ lib.concatLists (
            lib.mapAttrsToList (_: { configuration, ... }: cfgFiles configuration) cfg.specialisation
          );
      in
      [
        {
          source = pkgs.writeText "version" config.images.iso.version;
          target = "/version.txt";
        }
      ]
      ++ lib.unique (cfgFiles config);
  };
}

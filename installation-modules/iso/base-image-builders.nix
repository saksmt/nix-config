{ nixpkgs, ... }:
{
  process-recipe =
    {
      installation ? { },
      ...
    }:
    let
      imageGenParams = installation.make-image or { };
      modules =
        installation.make-image.modules or [
          "bedrock"
          "grub"
        ];

    in
    {
      modules = [
        (
          { lib, ... }:
          {
            imports = builtins.map (path: ./nixos-modules + ("/" + path)) modules;
            options.build = {
              squashfs-image = lib.mkOption {
                description = "[INTERNAL] Build squashfs image";
              };

              iso-image = lib.mkOption {
                description = "Build ISO image";
              };
            };
          }
        )
        (
          { pkgs, config, ... }:
          {
            build.squashfs-image = pkgs.build-images.squashfs-file {
              name = config.images.iso.base-name;
              comp = config.images.squashfs.compression;
              storeContents = config.images.iso.nix-store-contents;
            };
          }
        )
        (
          {
            pkgs,
            config,
            lib,
            ...
          }:
          {
            build.iso-image = pkgs.build-images.iso-file ({
              inherit (config.images.iso)
                contents
                volumeID
                applicationID
                publisher
                ;

              productName = config.images.iso.efiBootEntryName;
              productVersion = config.images.iso.efiBootEntryVersion;

              preload-grub-modules = config.images.iso.boot.grub.preload-modules;

              compressorTemplate = config.images.iso.compression;
              isoName = "${config.images.iso.base-name}.iso";
              squashfsImage = config.build.squashfs-image;
            });
          }
        )
      ];
    };
}

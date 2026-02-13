{ lib, ... }:
{
  options = {
    images.iso.base-name = lib.mkOption {
      default = "nixos";
      type = lib.types.str;
      description = ''
        The base name of the ISO image.
      '';
    };

    images.iso.boot.dir = lib.mkOption {
      default = "/boot";
      type = lib.types.path;
      description = ''
        Path to directory with all the kernels and params (/boot by default).
        Do not change without changing file layout on ISO.
      '';
    };

    images.iso.compression = lib.mkOption {
      default = null;
      example = "zstd -Xcompression-level 19 -T$NIX_BUILD_CORES --rm %s";
      type = lib.types.nullOr lib.types.str;
      description = ''
        Compress final iso image using given command template (must compress in-place)
      '';
    };

    images.squashfs.compression = lib.mkOption {
      default = "zstd -Xcompression-level 19";
      type = lib.types.nullOr lib.types.str;
      description = ''
        Compression settings to use for the squashfs nix store.
        `null` disables compression.
      '';
      example = "zstd -Xcompression-level 6";
    };

    images.iso.contents = lib.mkOption {
      example = lib.literalExpression ''
        [ { source = pkgs.memtest86 + "/memtest.bin";
            target = "boot/memtest.bin";
          }
        ]
      '';
      description = ''
        This option lists files to be copied to fixed locations in the
        generated ISO image.
      '';
    };

    images.iso.nix-store-contents = lib.mkOption {
      example = lib.literalExpression "[ pkgs.stdenv ]";
      description = ''
        This option lists additional derivations to be included in the
        Nix store in the generated ISO image.
      '';
    };

    images.iso.include-system-build-dependencies = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        Set this option to include all the needed sources etc in the
        image. It significantly increases image size. Use that when
        you want to be able to keep all the sources needed to build your
        system or when you are going to install the system on a computer
        with slow or non-existent network connection.
      '';
    };
  };
}

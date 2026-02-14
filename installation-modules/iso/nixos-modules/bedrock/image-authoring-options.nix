{ lib, config, ... }:
{
  options = {
    images.iso.efiBootEntryName = lib.mkOption {
      default = "NixOS LiveCD";
      type = lib.types.str;

      description = ''
        Name displayed in the system UEFI boot menu.
      '';
    };

    images.iso.efiBootEntryVersion = lib.mkOption {
      default = config.images.iso.version;
      type = lib.types.str;

      description = ''
        Symbolic version. Used by grub-mkrescue.
      '';
    };

    images.iso.volumeID = lib.mkOption {
      default = "NIXOS_LIVE";
      type = lib.types.strMatching "^[A-Z0-9_]{1,30}$";

      description = ''
        The volume ID for the ISO image.

        MUST be relatively unique (since it is used as an actual volume/partition ID) and have at most
        30 characters. Only A-Z, 0-9 and "_" are permitted.
      '';
    };

    images.iso.applicationID = lib.mkOption {
      default = "NIXOS";
      type = lib.types.strMatching "^.{1,128}$";
      description = ''
        The application ID for the ISO image.
        Max 128 characters.
      '';
    };

    images.iso.publisher = lib.mkOption {
      default = "NIXOS";
      type = lib.types.strMatching "^.{1,128}$";
      description = ''
        The publisher of the ISO image.
        Max 128 characters.
      '';
    };

    images.iso.version = lib.mkOption {
      default = config.system.nixos.label;
      type = lib.types.str;
      description = ''
        Arbitrary string to identify version. Written to the root of ISO in version.txt file.
      '';
    };
  };
}

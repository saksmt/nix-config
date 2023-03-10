uses: { config, pkgs, ... }:
with uses;

{ imports = [
    {
        boot.loader.grub.useOSProber = true;
    }


    (whenEFI {
        boot.loader.efi.canTouchEfiVariables = true;
        boot.loader.efi.efiSysMountPoint = "/boot";
        boot.loader.grub = {
          devices = [ "nodev" ];
          efiSupport = true;
          enable = true;
        };
    })

    (whenNotEFI {
        boot.loader.grub.device = "/dev/sda";
    })
]; }

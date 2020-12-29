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
          extraEntries = ''
            menuentry "Windows" {
              insmod part_gpt
              insmod fat
              insmod search_fs_uuid
              insmod chain
              search --fs-uuid --set=root 4C0B-3F2E
              chainloader /EFI/Microsoft/Boot/bootmgfw.efi
            }
          '';
        };
    })
]; }

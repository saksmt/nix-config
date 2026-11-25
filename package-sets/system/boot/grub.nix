{
  config,
  lib,
  features,
  ...
}:
with features;

lib.mkMerge [
  {
    module-for = [ "nixos" ];

    boot.loader.grub.useOSProber = lib.mkDefault true;
    boot.initrd.systemd.enable = true;
    boot.loader.grub.enable = lib.mkDefault true;
    catppuccin.grub.enable = true;
  }
  (EFI.whenEnabled {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
    boot.loader.grub = {
      devices = [ "nodev" ];
      efiSupport = true;
      extraEntries = ''
        menuentry "Firmware / BIOS Setup" {
          fwsetup
        }
      '';
    };
  })
  (EFI.whenDisabled {
    boot.loader.grub.device = lib.mkDefault "/dev/sda";
  })
]

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
  # niceties in boot only needed if there are niceties after boot
  (GUI.whenEnabled {
    boot.plymouth.enable = lib.mkDefault true;
    boot.kernelParams = lib.mkDefault [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      # "i915.fastboot=1" # alternative below
      "plymouth.use-simpledrm"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    boot.consoleLogLevel = lib.mkDefault 0;
    boot.initrd.verbose = lib.mkDefault false;
    catppuccin.plymouth.enable = true;
  })
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

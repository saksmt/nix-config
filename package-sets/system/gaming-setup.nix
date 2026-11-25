{
  lib,
  pkgs,
  features,
  ...
}:

lib.mkMerge [
  {
    module-for = [ "nixos" ];
  }
  (features.gaming.whenEnabled {
    hardware.graphics.enable32Bit = true;
    hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

    services.udev.extraRules = ''
      # Keep Flydigi Vader 5 Pro 2.4GHz dongle powered for S3/s2idle wakeup
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="37d7", ATTR{idProduct}=="2401", ATTR{power/wakeup}="enabled"

      # Grant raw HID access for Steam Input and profile tools without root
      KERNEL=="hidraw*", ATTRS{idVendor}=="37d7", ATTRS{idProduct}=="2401", MODE="0660", GROUP="input", TAG+="uaccess"
    '';
  })
]

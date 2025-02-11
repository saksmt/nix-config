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
  })
]

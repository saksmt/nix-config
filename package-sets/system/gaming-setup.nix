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
    hardware.opengl.driSupport32Bit = true;
    hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    hardware.pulseaudio.support32Bit = true;
  })
]

{
  pkgs,
  lib,
  features,
  ...
}:
lib.mkMerge [
  {
    module-for = [ "nixos" ];
  }
  (features.android.whenEnabled {
    install.packages = [ pkgs.android-tools ];
  })

]

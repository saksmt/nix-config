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
    programs.adb.enable = true;
  })

]

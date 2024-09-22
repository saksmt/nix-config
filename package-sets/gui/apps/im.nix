{
  features,
  lib,
  pkgs,
  ...
}:
with features;

lib.mkMerge [
  {
    module-for = [ "hm" ];
  }

  (GUI.whenEnabled {
    install.packages = with pkgs; [ tdesktop ] ++ (lib.lists.optional gaming.isEnabled discord);
  })
]

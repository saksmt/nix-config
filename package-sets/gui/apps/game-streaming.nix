{
  features,
  pkgs,
  lib,
  ...
}:
with features;
lib.mkMerge [
  {
    module-for = [ "hm" ];
  }

  ((GUI.and gaming).whenEnabled {
    install.packages = [ pkgs.moonlight-qt ];
  })
]

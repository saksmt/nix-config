{
  features,
  lib,
  pkgs,
  ...
}:

lib.mkMerge [
  {
    module-for = [ "hm" ];
  }

  (features.GUI.whenEnabled {
    install.packages = with pkgs; [
      davinci-resolve
      darktable
    ];
  })
]

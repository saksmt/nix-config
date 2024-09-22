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
      smplayer
      mpv

      (deadbeef-with-plugins.override {
        plugins = [ deadbeefPlugins.mpris2 ];
      })
    ];
  })
]

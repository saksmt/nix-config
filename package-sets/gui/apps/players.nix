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
      plexamp
      playerctl # commandline controls for MPRIS

      (deadbeef-with-plugins.override {
        plugins = [ deadbeefPlugins.mpris2 ];
      })
    ];
  })
]

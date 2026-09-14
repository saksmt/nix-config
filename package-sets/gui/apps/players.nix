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
    install.packages =
      with pkgs;
      [
        mpv
        plexamp
        playerctl # commandline controls for MPRIS
      ]
      ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        smplayer
      ]);
  })
]

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
      ]
      ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        smplayer
        plexamp # <- it exists, but not in nix
      ]);
  })
]

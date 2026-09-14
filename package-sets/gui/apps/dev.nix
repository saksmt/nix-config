{
  lib,
  features,
  pkgs,
  ...
}:

lib.mkMerge [
  {
    module-for = [ "hm" ];
  }

  ((features.GUI.and features.dev.common).whenEnabled {
    install.packages = [
      pkgs.jetbrains.idea
    ]
    ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.freemind # <- exists, but not on nix
    ]);
  })
]

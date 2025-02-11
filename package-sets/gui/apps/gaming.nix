{
  features,
  pkgs,
  lib,
  ...
}:
with features;
lib.mkMerge [
  {
    #that should've been on hm-level but since hm is shit and I don't want to copy paste steam module here we are...
    module-for = [ "nixos" ];
  }

  ((GUI.and gaming).whenEnabled {
    programs.steam.enable = true;
    install.packages = [ pkgs.wineWowPackages.stable pkgs.prismlauncher ];
  })
]

{ whenGaming, ... } : { config, pkgs, ... }:

whenGaming {
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [ 
    discord
    minecraft
    wineWowPackages.stable
  ];
}

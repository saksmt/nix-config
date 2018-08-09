{ config, pkgs, ... }:

{
  services.xserver.windowManager.awesome.enable = true;
  services.xserver.windowManager.awesome.package = pkgs.awesome;
  environment.systemPackages = with pkgs; [ 
    scrot 
    feh 
    lua
    lxappearance
    pavucontrol
  ];
}

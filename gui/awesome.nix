{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenNotNoX {
  services.xserver.windowManager.awesome.enable = true;
  services.xserver.windowManager.awesome.package = pkgs.awesome;
  environment.systemPackages = with pkgs; [ 
    scrot 
    feh 
    lua
    lxappearance
    pavucontrol
    paper-icon-theme
  ];

  services.xserver.displayManager.sddm.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.sddm.startSession = true;
}

{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

{
  environment.systemPackages = with pkgs; [
    roxterm xarchiver keepassxc mate.mate-icon-theme-faenza 
  ];

  services.xserver.enable = true;

  fonts.fonts = with pkgs; [ ubuntu_font_family hasklig terminus_font terminus_font_ttf ];

} // (whenLaptop {
    services.xserver.libinput.enable = true;
    services.xserver.libinput.disableWhileTyping = true;
    services.xserver.multitouch.enable = true;
    services.xserver.multitouch.ignorePalm = true;
})

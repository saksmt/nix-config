{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    roxterm
  ];

  services.xserver.enable = true;

  services.xserver.libinput.enable = true;
  services.xserver.libinput.disableWhileTyping = true;
  services.xserver.multitouch.enable = true;
  services.xserver.multitouch.ignorePalm = true;

  fonts.fonts = with pkgs; [ ubuntu_font_family hasklig terminus_font terminus_font_ttf ];

}

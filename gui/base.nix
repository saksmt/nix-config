{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenNotNoX { imports = [{

  environment.systemPackages = with pkgs; [
    roxterm xarchiver keepassxc mate.mate-icon-theme-faenza 
  ];

  services.xserver.enable = true;

  fonts.fonts = with pkgs; [ ubuntu_font_family hasklig terminus_font terminus_font_ttf ];
  fonts.fontconfig.defaultFonts.monospace = [ "Hasklig" ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Ubuntu" ];
  fonts.fontconfig.defaultFonts.serif = [ "Ubuntu" ];

  services.gnome3.gnome-keyring.enable = true;

} (whenLaptop {
    services.xserver.libinput.enable = true;
    services.xserver.libinput.disableWhileTyping = true;
    services.xserver.multitouch.enable = true;
    services.xserver.multitouch.ignorePalm = true;
})]; }

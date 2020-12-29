{ whenNotNoX, ... } : { pkgs, ... }: whenNotNoX {

  fonts.fonts = with pkgs; [ ubuntu_font_family hasklig terminus_font terminus_font_ttf ];
  fonts.fontconfig.defaultFonts.monospace = [ "Hasklig" ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Ubuntu" ];
  fonts.fontconfig.defaultFonts.serif = [ "Ubuntu" ];

}

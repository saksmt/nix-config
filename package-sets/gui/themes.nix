{
  features,
  pkgs,
  lib,
  ...
}:
# todo: stylix?
lib.mkMerge [
  {
    module-for = [ "hm" ];
  }
  (features.GUI.whenEnabled {
    gtk.enable = true;
    gtk.cursorTheme = {
      size = if features.HiDPI.isEnabled then 32 else 24;
      package = pkgs.vanilla-dmz;
      name = "DMZ-Black";
    };
    gtk.font = {
      package = pkgs.sarasa-gothic;
      name = "Sarasa UI CL Light"; # try alt: Sarasa Gothic
      size = 12;
    };
    gtk.iconTheme = {
      package = pkgs.paper-icon-theme;
      name = "Paper-Mono-Dark";
    };
    gtk.colorScheme = "dark";
    install.packages = with pkgs; [
      vanilla-dmz
      numix-gtk-theme
      paper-icon-theme
    ];
  })
]

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
    catppuccin.gtk.icon.enable = true;
    install.packages = with pkgs; [
      vanilla-dmz
      numix-gtk-theme
      numix-icon-theme-square
      paper-icon-theme
    ];
  })
]

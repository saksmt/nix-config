{
  features,
  pkgs,
  lib,
  config,
  ...
}:

{
  module-for = [ "hm" ];
}
// (
  if features.GUI.isEnabled then
    {
      imports = [ ../barebones/x.nix ];

      install.packages = [
        pkgs.lua
        pkgs.rofi
      ];

      services.clipcat.enable = lib.mkDefault true;

      windowManager.awesome-iwm.enable = true;
      # This allows for seamless modification of default kitty package,
      # for example in case of nixGL
      windowManager.awesome-iwm.terminal = "${config.programs.kitty.package}/bin/kitty";
      xsession.windowManager.awesome.enable = true;
    }
  else
    { }
)

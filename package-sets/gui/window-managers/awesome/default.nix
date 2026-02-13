{
  features,
  pkgs,
  lib,
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

      xsession.windowManager.awesome.enable = true;
    }
  else
    { }
)

{
  lib,
  features,
  ...
}:
with features;

{
  programs.hyprland.enable = lib.mkDefault GUI.isEnabled;
  programs.hyprland.withUWSM = lib.mkDefault GUI.isEnabled;
}

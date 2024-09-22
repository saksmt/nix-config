{
  lib,
  features,
  ...
}:
with features;
{
  module-for = [ "nixos" ];

  services.gnome.gnome-keyring.enable = lib.mkDefault GUI.isEnabled;
  services.gvfs.enable = lib.mkDefault GUI.isEnabled;
  services.udisks2.enable = lib.mkDefault GUI.isEnabled;

  programs.dconf.enable = lib.mkDefault GUI.isEnabled;
}

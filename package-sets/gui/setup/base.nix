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

  environment.sessionVariables = wayland.whenEnabled {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

}

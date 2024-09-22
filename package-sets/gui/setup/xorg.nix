{
  lib,
  features,
  pkgs,
  ...
}:
with features;

lib.mkMerge [
  {
    module-for = [ "nixos" ];

    install.packages = lib.lists.optional GUI.isEnabled pkgs.xsel;

    services.xserver.enable = lib.mkDefault GUI.isEnabled;
    services.xserver.updateDbusEnvironment = lib.mkDefault GUI.isEnabled;

    services.libinput.enable = lib.mkDefault GUI.isEnabled;
    services.libinput.touchpad.disableWhileTyping = lib.mkDefault (laptop.isEnabled && GUI.isEnabled);
  }

  (HiDPI.whenEnabled {
    services.xserver.dpi = 140;
  })
]

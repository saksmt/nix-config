{
  features,
  lib,
  ...
}:
with features;

lib.mkMerge [
  {
    module-for = [ "nixos" ];
  }

  (GUI.whenEnabled {
    security.pam.services.sddm.enableGnomeKeyring = lib.mkDefault true;
    security.pam.services.sddm.startSession = lib.mkDefault true;

    services.xserver.displayManager = {
      sddm.enable = true;
      sddm.enableHidpi = lib.mkDefault HiDPI.isEnabled;

      defaultSession = "home-managed_x";
      session = [
        {
          manage = "desktop";
          name = "home-managed_x";
          start = ''exec $HOME/.xsession'';
        }
      ];
    };
  })
]

{ features, lib, ... }:
with features;

lib.mkMerge [
  { module-for = [ "nixos" ]; }

  (GUI.whenEnabled {
    security.pam.services.sddm.enableGnomeKeyring = lib.mkDefault true;
    security.pam.services.sddm.startSession = lib.mkDefault true;

    services.xserver.displayManager.session = [
      {
        manage = "desktop";
        name = "home-managed_x";
        start = ''exec $HOME/.xsession'';
      }
    ];
    services.displayManager = {
      sddm.enable = true;
      # this setting enables **automatic** HiDPI scaling, so lets hope it
      # does not mess up *too* badly
      sddm.enableHidpi = lib.mkDefault true;

      defaultSession = "home-managed_x";
    };
    catppuccin.sddm.enable = true;
    catppuccin.sddm.userIcon = true;
    catppuccin.sddm.loginBackground = true;
#    catppuccin.sddm.fontSize = if HiDPI.isEnabled then "24" else "14";
  })
]

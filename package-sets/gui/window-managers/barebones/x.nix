{
  features,
  pkgs,
  lib,
  ...
}:

lib.mkMerge [
  {
    module-for = [ "hm" ];
  }

  (features.GUI.whenEnabled {
    install.packages = with pkgs; [
      scrot
      feh
      lxappearance
      pavucontrol

      pcmanfm
      xarchiver
    ];
    services.gpg-agent.pinentryPackage = pkgs.pinentry-curses;
    xsession.enable = true;

    services.xscreensaver.enable = true;
    systemd.user.services.xscreensaver = {
      # disable auto start
      Install.WantedBy = lib.mkForce [];
    };
  })
]

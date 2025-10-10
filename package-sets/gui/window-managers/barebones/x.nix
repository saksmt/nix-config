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
      xsel
    ];
    services.gpg-agent.pinentry.package = pkgs.pinentry-curses;
    xsession.enable = true;

    services.xscreensaver.enable = false; # param-PAM-pain... need extensive research into how to make it work and what and how xscreensaver uses
    systemd.user.services.xscreensaver = {
      # disable auto start
      Install.WantedBy = lib.mkForce [ ];
    };
  })
]

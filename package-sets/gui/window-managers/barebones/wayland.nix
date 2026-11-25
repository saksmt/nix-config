{
  features,
  pkgs,
  lib,
  config,
  ...
}:

lib.mkMerge [
  {
    module-for = [ "hm" ];
  }

  (features.GUI.whenEnabled {
    install.packages = with pkgs; [
      pavucontrol

      pcmanfm
      xarchiver
      wl-clipboard
      qimgv
      nwg-look
    ];
    services.gpg-agent.pinentry.package = pkgs.pinentry-rofi;

    xdg.configFile."uwsm/env".source =
      "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
  })
]

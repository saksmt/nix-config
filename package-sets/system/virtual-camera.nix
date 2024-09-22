{
  config,
  lib,
  features,
  pkgs,
  ...
}:

lib.mkMerge [
  {
    module-for = [ "nixos" ];
  }
  (features.GUI.whenEnabled {
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    systemd.services.v4l2-obs = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kmod}/bin/modprobe v4l2loopback card_label='OBS Virtual Camera' video_nr=7 exclusive_caps=1";
        ExecStop = "${pkgs.kmod}/bin/rmmod v4l2loopback";
        RemainAfterExit = "yes";
      };
    };
  })
]

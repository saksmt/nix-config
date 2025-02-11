{
  pkgs,
  lib,
  features,
  ...
}:
lib.mkMerge [
  {
    module-for = [ "nixos" ];
  }
  (features.bluetooth.whenEnabled {
    hardware.enableRedistributableFirmware = lib.mkDefault true;
    hardware.bluetooth.enable = true;

    systemd.user.services.mpris-proxy = {
      enable = true;
      path = [ pkgs.bluez ];
      description = "MPRIS proxy (media controls over bluetooth)";
      requires = [ "dbus.service" ];
      after = [
        "network.target"
        "sound.target"
      ];
      script = "mpris-proxy";
      wantedBy = [ "default.target" ];
    };

    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };

  })

]

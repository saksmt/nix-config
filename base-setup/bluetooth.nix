uses: { config, pkgs, ... }:
with uses;

whenBluetooth { 
    hardware.enableRedistributableFirmware = true;
    hardware.bluetooth.enable = true;
    
    systemd.user.services.mpris-proxy = {
        enable = true;
        path = [ pkgs.bluez ];
        description = "MPRIS proxy (controls over bluetooth)";
        requires = [ "dbus.service" ];
        after = [ "network.target" "sound.target" ];
        script = "mpris-proxy";
        wantedBy = [ "default.target" ];
    };
}

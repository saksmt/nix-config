{ lib, ... }:
{
  services.transmission.enable = true;
  services.transmission.openFirewall = true;
  services.transmission.settings = {
    dht-enabled = true;
    lpd-enabled = true;
    pex-enabled = true;
    ratio-limit-enabled = true;
    ratio-limit = 2;
    rpc-enabled = true;
    rpc-url = "/transmission/";
    utp-enabled = true;
    peer-limit-global = 30000;
    peer-limit-per-torrent = 1000;
    download-queue-enabled = true;
    download-queue-size = 30;
    seed-queue-enabled = true;
    seed-queue-size = 60;

    blocklist-enabled = lib.mkDefault true;
    blocklist-url = lib.mkDefault "http://list.iblocklist.com/?list=bt_level1&fileformat=p2p&archiveformat=gz";

    download-dir = lib.mkDefault "/data";

    rpc-port = lib.mkDefault 9091;
    rpc-bind-address = lib.mkDefault "0.0.0.0";

    rpc-whitelist-enabled = lib.mkDefault true;
    rpc-host-whitelist-enabled = lib.mkForce false; # force disallow this insecure stuff
    rpc-whitelist = lib.mkDefault "127.0.0.1,192.168.*.*";
  };
}

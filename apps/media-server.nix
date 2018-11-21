{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenMediaServer {
  services.plex.enable = true;
  services.nfs.server.enable = true;
  services.transmission.enable = true;
  services.transmission.settings = {
    block-list-enabled = true;
    block-list-url = "http://list.iblocklist.com/?list=bt_level1&fileformat=p2p&archiveformat=gz";
    dht-enabled = true;
    download-dir = "/data";
    lpd-enabled = true;
    pex-enabled = true;
    ratio-limit-enabled = true;
    ratio-limit = 2;
    rpc-enabled = true;
    rpc-url = "/transmission/";
    rpc-port = 9091;
    rpc-whitelist = "127.0.0.1,192.168.*.*";
    rpc-whitelist-enabled = true;
    utp-enabled = true;
  };

  nixpkgs.config.allowUnfree = true;
  programs.java.package = pkgs.oraclejre;
  programs.java.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 80 8080 8688 8443 8006 8005 32400 9091 ];

  networking.firewall.allowedTCPPortRanges = [ { from = 10000; to = 65535; } ];
  networking.firewall.allowedUDPPortRanges = [ { from = 10000; to = 65535; } ];
}
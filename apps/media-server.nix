{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenMediaServer {
  nixpkgs.config.oraclejdk.accept_license = true;
  services.plex.enable = true;
  services.nfs.server.enable = true;
  services.nfs.server.lockdPort = 4001;
  services.nfs.server.mountdPort = 4002;
  services.nfs.server.statdPort = 4000;
  services.transmission.enable = true;
  services.transmission.settings = {
    blocklist-enabled = true;
    blocklist-url = "http://list.iblocklist.com/?list=bt_level1&fileformat=p2p&archiveformat=gz";
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
    rpc-host-whitelist-enabled = false;
    utp-enabled = true;
    peer-limit-global = 30000;
    peer-limit-per-torrent = 1000;
    download-queue-enabled = true;
    download-queue-size = 30;
    seed-queue-enabled = true;
    seed-queue-size = 60;
  };

  services.vsftpd.enable = true;
  services.vsftpd.writeEnable = true;
  services.vsftpd.localUsers = true;
  services.vsftpd.anonymousUser = false;
  services.vsftpd.userlistEnable = true;

  nixpkgs.config.allowUnfree = true;
  programs.java.package = pkgs.oraclejre;
  programs.java.enable = true;

  services.docker.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 21 20 80 8080 8688 8443 8006 8005 32400 9091 4000 4001 4002 111 2049 ];
  networking.firewall.allowedUDPPorts = [ 4000 4001 4002 111 2049 ];

  networking.firewall.allowedTCPPortRanges = [ { from = 10000; to = 65535; } ];
  networking.firewall.allowedUDPPortRanges = [ { from = 10000; to = 65535; } ];
}

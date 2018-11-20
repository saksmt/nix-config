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
    rpc-white-list = "127.0.0.1,192.168.*.*";
    rpc-white-list-enabled = true;
    utp-enabled = true;
  };

  nixpkgs.config.allowUnfree = true;
  programs.java.package = pkgs.oraclejre;
  programs.java.enable = true;
}
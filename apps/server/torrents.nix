{ whenMediaServer, ... }: _:

whenMediaServer {
    services.transmission.enable = true;
    services.transmission.openFirewall = true;
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
        rpc-bind-address = "0.0.0.0";
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
}

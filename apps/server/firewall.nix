{ whenServer, ... }: _:

whenServer {
    networking.firewall.allowedTCPPorts = [ 22 21 20 80 8080 8688 8443 8006 8005 32400 9091 4000 4001 4002 111 2049 ];
    networking.firewall.allowedUDPPorts = [ 4000 4001 4002 111 2049 ];

    networking.firewall.allowedTCPPortRanges = [ { from = 10000; to = 65535; } ];
    networking.firewall.allowedUDPPortRanges = [ { from = 10000; to = 65535; } ];
}
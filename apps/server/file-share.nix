{ whenMediaServer, ... }: _:

whenMediaServer {
    services.nfs.server.enable = true;
    
    services.nfs.server.lockdPort = 4001;
    services.nfs.server.mountdPort = 4002;
    services.nfs.server.statdPort = 4000;
}

{ whenMediaServer, ... }: _:

whenMediaServer {
    services.vsftpd.enable = true;
    services.vsftpd.writeEnable = true;
    services.vsftpd.localUsers = true;
    services.vsftpd.anonymousUser = false;
    services.vsftpd.userlistEnable = true;
}

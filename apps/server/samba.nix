{ whenServer, ... } : _ :

whenServer {
    services.samba.enable = true;
    services.samba.shares = { 
        root = {
            path = "/root"
            "read only" = false;
            "valid users" = "@samba-root-access"
            "guest ok" = false;
            browsable = true;
            writable = true;
        };

        data = {
            path = "/data"
            "read only" = false;
            "valid users" = "@samba-data-access"
            "guest ok" = false;
            browsable = true;
            writable = true;
        };

        files = {
            path = "/data/files"
            "read only" = false;
            "valid users" = "@samba-files-access"
            "guest ok" = false;
            browsable = true;
            writable = true;
        };
     };
}
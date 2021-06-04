{ whenServer, ... } : { pkgs, ... } :

whenServer {
    environment.systemPackages = [ pkgs.samba ];

    services.samba.enable = true;
    services.samba.shares = { 
        root = {
            path = "/";
            "valid users" = "@samba-root-access";
            "guest ok" = "no";
            "force user" = "";
            "force group" = "";
            browsable = "yes";
            writable = "yes";
            comment = "Server filesystem root";
        };

        data = {
            path = "/data";
            "valid users" = "@samba-data-access";
            "guest ok" = "no";
            browsable = "yes";
            writable = "yes";
            comment = "Медиа и данные";
        };

        files = {
            path = "/data/files/%u";
            "guest ok" = "no";
            browsable = "yes";
            writable = "yes";
            comment = "Персональные файлы";
        };
    };
    services.samba.extraConfig = ''
      workgroup = WORKGROUP
      server string = smt-home-server
      server role = standalone server
      force user = nfs
      force group = transmission
      log level = 2 full_audit:4
    '';
}
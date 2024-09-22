{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.server.samba = with lib; {
    data-dir = mkOption {
      type = types.string;
      description = "Path to directory with data";
      default = "/data";
    };
    valid-users-on = {
      root = mkOption {
        type = types.listOf types.string;
        description = "List of users permitted to access /";
        default = "@samba-root-access";
      };
      data = mkOption {
        type = types.listOf types.string;
        description = "List of users permitted to access /data";
        default = "@samba-data-access";
      };
    };
    default-user = mkOption {
      type = types.string;
      description = "User name to use/force by default";
      default = "nfs";
    };
    default-group = mkOption {
      type = types.string;
      description = "User group to use/force by default";
      default = "transmission";
    };
  };

  config.environment.systemPackages = [ pkgs.samba ];

  config.services.samba.enable = true;
  config.services.samba.invalidUsers = [ ];
  config.services.samba.shares = {
    root = {
      path = "/";
      "valid users" = config.server.samba.valid-users-on.root;
      "guest ok" = "no";
      "force user" = "";
      "force group" = "";
      browsable = "yes";
      writable = "yes";
      comment = "Server filesystem root";
    };

    data = {
      path = config.server.samba.data-dir;
      "valid users" = config.server.samba.valid-users-on.data;
      "guest ok" = "no";
      browsable = "yes";
      writable = "yes";
      comment = "Медиа и данные";
    };

    files = {
      path = "${config.server.samba.data-dir}/files/%u";
      "guest ok" = "no";
      browsable = "yes";
      "force user" = "";
      "create mask" = "664";
      "directory mask" = "775";
      "force group" = config.server.samba.default-group;
      writable = "yes";
      comment = "Персональные файлы";
    };
  };
  config.services.samba.extraConfig = ''
    workgroup = WORKGROUP
    server string = smt-home-server
    server role = standalone server
    force user = ${config.server.samba.default-user}
    force group = ${config.server.samba.default-group}
    log level = 2 full_audit:4
  '';
}

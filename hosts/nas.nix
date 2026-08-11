{ nixos-hardware, feature-definitions, ... }:
rec {
  imports = [
    (
      { pkgs, ... }:
      {
        system.stateVersion = "26.05";

        users.users.root.shell = pkgs.zsh;
        users.users.smt.shell = pkgs.zsh;

        # iosevka is too heavy to build on NAS
        # fix this after setting up proper private cache
        fonts.fontconfig.enable = true;
        fonts.packages = [ pkgs.hasklig ];
      }
    )
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "data-pool" ];

  users.users.smt = {
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  home-manager.users.smt =
    { pkgs, ... }:
    {
      home.stateVersion = "26.05";
    };

  networking.hostName = "smt-nas";
  networking.hosts = {
    "127.0.0.1" = [ "smt-nas" ];
  };

  installation = {
    features = with feature-definitions; [
      wifi
      GUI.disabled
      EFI
    ];

    package-sets = [
      "system"

      "server/sshd"

      "runtime/docker"
      "runtime/jvm"

      "cli"
    ];

    home-manager = {
      enabled = true;

      # force management of zshrc and stuff through home-manager
      programs.zsh.enable = true;

      programs.git = {
        enable = true; # force management of git config through home-manager
        userName = "Kirill Saksin";
        userEmail = "smt@saksmt.dev";
      };

      installation = {
        package-sets = [

          "user-preferences"

        ];
        features = installation.features;
      };
    };
  };
}

{ nixos-hardware, feature-definitions, ... }:
rec {
  imports = [
    (
      { pkgs, config, ... }:
      {
        system.stateVersion = "26.05";

        users.users.root.shell = pkgs.zsh;
        users.users.smt.shell = pkgs.zsh;
      }
    )
  ];

  users.users.smt = {
    extraGroups = [
      "wheel"
    ];
  };

  home-manager.users.smt =
    { pkgs, ... }:
    {
      home.stateVersion = "26.05";
    };

  networking.hostName = "smt-sof-server";
  networking.hosts = {
    "127.0.0.1" = [ "smt-sof-server" ];
  };

  installation = {
    features = with feature-definitions; [
      GUI.disabled
      EFI
    ];

    package-sets = [
      "system"
      "system/boot/systemd"

      "server/sshd"

      "runtime/docker"
      "runtime/jvm"

      "dev/xdg-obedience"

      "cli"
    ];

    home-manager = {
      enabled = true;

      # force management of zshrc and stuff through home-manager
      programs.zsh.enable = true;

      # force management of git config through home-manager
      programs.git.enable = true;
      programs.git.settings.user = {
        name = "Kirill Saksin";
        email = "smt@saksmt.dev";
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

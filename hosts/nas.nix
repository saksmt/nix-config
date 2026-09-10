{ nixos-hardware, feature-definitions, ... }:
rec {
  imports = [
    (
      { pkgs, config, ... }:
      {
        system.stateVersion = "26.05";

        users.users.root.shell = pkgs.zsh;
        users.users.smt.shell = pkgs.zsh;

        # iosevka is too heavy to build on NAS
        # fix this after setting up proper private cache
        fonts.fontconfig.enable = true;
        fonts.packages = [ pkgs.hasklig ];

        install.packages = [ pkgs.sanoid ];

        # wifi
        # automatically switches from cursed CD-ROM mode
        hardware.usb-modeswitch.enable = true;
        # enable firmware for wifi dongle
        hardware.enableRedistributableFirmware = true;

        # reverse tunnel to expose dynamically ip-ed nas
        systemd.services.reverse-ssh-tunnel = {
          enable = true;

          description = "Reverse SSH Tunnel to Static Server";
          after = [
            "network-online.target"
            "sshd.service"
          ];
          wants = [ "network-online.target" ];

          requires = [ "sshd.service" ];

          # Ensures the service starts automatically on boot
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            User = "smt";
            Restart = "always";
            RestartSec = "10";

            # The SSH command is kept on one line to prevent systemd parsing errors
            ExecStart =
              let
                sshCommandOpts = [
                  "-N" # no command
                  "-T" # no tty
                  "-C" # compression
                ]
                ++ (builtins.map (x: "-o ${x}") [
                  "ServerAliveInterval=15"
                  "ServerAliveCountMax=3"
                  "ExitOnForwardFailure=yes"
                  "StrictHostKeyChecking=no"
                ]);
                server = "home.saksmt.dev";
                serverUser = "backup-pull";
                nasServerKeyPath = "/root/.ssh/id_ed25519";
                portToUseOnServer = "10022";
                # building the command:
                ssh = "${pkgs.openssh}/bin/ssh";
                forwardingSpec = "0.0.0.0:${portToUseOnServer}:localhost:22";
                hostSpec = "${serverUser}@${server}";
                command = builtins.concatStringsSep " " (
                  builtins.concatLists [
                    [ ssh ]
                    sshCommandOpts
                    [
                      "-i"
                      nasServerKeyPath
                    ]
                    [
                      "-R"
                      forwardingSpec
                    ]
                    [ hostSpec ]
                  ]
                );
              in
              command;
          };
        };
      }
    )
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "data-pool" ];

  # watchdog

  boot.blacklistedKernelModules = [ "iTCO_wdt" ];
  boot.initrd.kernelModules = [ "it87_wdt" ];
  boot.kernelParams = [ "it87_wdt.timeout=180" ];
  boot.initrd.systemd.settings.Manager = {
    RuntimeWatchdogSec = "1m";
    RebootWatchdogSec = "2m";
  };
  systemd.settings.Manager = {
    RuntimeWatchdogSec = "1m";
    RebootWatchdogSec = "2m";
  };

  # cleanup stale snapshots
  services.sanoid = {
    enable = true;
    templates.backupImportant = {
      hourly = 6;
      daily = 3;
      monthly = 2;
      yearly = 1;
      autoprune = true;
      autosnap = false;
    };
    datasets."data-pool" = {
      useTemplate = [ "backupImportant" ];
      recursive = true;
    };
  };

  services.syncoid = {
    enable = true;

    # *-*-* 14:00:00 Europe/Moscow
    interval = [];
    sshKey = "/var/lib/syncoid/.ssh/id_ed25519";

    commands.backup-pull = {
      source = "backup-pull@home.saksmt.dev:data-pool/data/important";
      target = "data-pool/data/important";
      recursive = true;
    };
  };

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

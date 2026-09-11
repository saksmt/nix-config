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

        install.packages = [ pkgs.sanoid pkgs.curl ];

        services.syncoid.commands.backup-pull.hookPackages = [ pkgs.jq ];

        programs.ssh.extraConfig = ''
        Host home.saksmt.dev
          ServerAliveInterval 15
          ServerAliveCountMax 4
        '';

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

    interval = "*-*-* 14:00:00 Europe/Moscow";
    sshKey = "/var/lib/syncoid/.ssh/id_ed25519";

    commands.backup-pull = {
      source = "backup-pull@home.saksmt.dev:data-pool/data/important";
      target = "data-pool/data/important";
      recursive = true;
      sendOptions = "c";
      extraArgs = [ "--compress=none" "--mbuffer-size=512M" ];

      preHook = ''
        # size before
        BEFORE_BYTES="$(zfs get -H -p -o value used "$TARGET" 2>/dev/null || echo "0")"

        SNAPSHOT_LIST_BEFORE_FILE="$(mktemp)"
        zfs list -t snapshot --json | jq '.datasets | keys | unique' > "''${SNAPSHOT_LIST_BEFORE_FILE}"
      '';

      postHook = ''
      if [ "$EXIT_STATUS" -eq 0 ] && [ -n "''${BEFORE_BYTES:-}" ]; then
        AFTER_BYTES=$(zfs get -H -p -o value used "$TARGET" 2>/dev/null || echo "0")
        BYTES_DIFF=$(($AFTER_BYTES - $BEFORE_BYTES))

        transferred="$(numfmt --to=iec $BYTES_DIFF)"
        priority=default

        if ! [ "$BYTES_DIFF" -gt 0 ]; then
          priority=low
        fi

        snapshot_list_after="$(mktemp)"
        zfs list -t snapshot --json | jq '.datasets | keys | unique' > "''${snapshot_list_after}"

        {
        echo "Backup successful, transferred: $transferred"

        echo

        echo "Pulled snapshots:"
        jq '. - input' ''${snapshot_list_after} ''${SNAPSHOT_LIST_BEFORE_FILE} | \
          jq '. | map(ltrimstr("data-pool/data/important") | split("@"))' | \
          jq '. | map(.[0] |= (ltrimstr("/") | if . == "" then "/" else . end))' | \
          jq '. | group_by(.[0])' | \
          jq -r '. | map("\(.[0][0])\n\(. | map(" - \(.[1])") | join("\n"))") | .[]'

        } | \
        curl \
         -H "$(< /var/lib/syncoid/ntfy-auth-header)" \
         -H "Title: NAS backup successful" \
         -H "Tags: heavy_check_mark" \
         -H "Priority: $priority" \
         -d @- \
         "https://$(</var/lib/syncoid/ntfy-host)/system_server_backup" || true
      else
        echo "NAS backup failed with exit code: $EXIT_STATUS" | \
        curl \
         -H "$(< /var/lib/syncoid/ntfy-auth-header)" \
         -H "Title: NAS backup failed" \
         -H "Tags: no_entry" \
         -H "Priority: urgent" \
         -d @- \
         "https://$(</var/lib/syncoid/ntfy-host)/system_server_backup" || true
      fi

      rm -f "''${SNAPSHOT_LIST_BEFORE_FILE}" &>/dev/null || true
      rm -f "''${snapshot_list_after}" &>/dev/null || true
      '';
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

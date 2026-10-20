{ nixos-hardware, feature-definitions, ... }:
rec {
  imports = [
    {
      hardware.nvidia = {
        enabled = true;
        open = true;
        modesetting.enable = true;
      };

      services.xserver.videoDrivers = [ "nvidia" ];
    }
    ({ pkgs, ... }: {
      system.stateVersion = "26.05";

      users.users.smt.shell = pkgs.zsh;
      users.users.root.shell = pkgs.zsh;

      services.udev.extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl", GROUP="users"

        # AMD Ryzen tuning
        # Instruct the scheduler to prefer the high-frequency CCD (CCD1) over the V-Cache CCD (CCD0), "cache" is alternative value
        SUBSYSTEM=="platform", DRIVER=="amd_x3d_vcache", ATTR{amd_x3d_mode}="frequency"
      '';

      boot.kernelParams = [ "amd_pstate=active" ];
      boot.kernel.sysctl = {
        # more than enough memory to not overrely on swap
        "vm.swappiness" = 20;
      };
    })
  ];

  users.users.smt = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "kvm"
      "adbusers"
    ];
  };

  home-manager.users.smt =
    { pkgs, ... }:
    {
      home.stateVersion = "26.05";
    };

  networking.hostName = "smt-pc";
  networking.hosts = {
    "127.0.0.1" = [ "smt-pc" ];
  };

  installation = {
    unstables =
      {
        from,
        unstable,
        master,
        copy-of,
        ...
      }:
      {
        jetbrains.idea = from master;
        opencode = from master;
        opencode-desktop = from master;

        wrapOBS = from unstable;
        obs-studio-plugins = from unstable;

        unstable = copy-of unstable;
      };

    features = with feature-definitions; [
      GUI
      EFI
      HiDPI

      gaming

      dev.all
      android
    ];

    package-sets = [
      "system"
      "system/fonts"
      "runtime/docker"
      "runtime/jvm"

      "cli"
      "dev"

      "gui/setup/base"
      "gui/setup/sddm"
      "gui/setup/hyprland"

      "gui/apps/gaming"
    ];

    home-manager = {
      enabled = true;

      # force management of zshrc and stuff through home-manager
      programs.zsh.enable = true;

      programs.git.enable = true; # force management of git config through home-manager
      programs.git.settings.user = {
        name = "Kirill Saksin";
        email = "smt@saksmt.dev";
      };

      installation = {
        package-sets = [
          "gui/apps/base"
          "gui/apps/dev"
          "gui/apps/im"
          # "gui/apps/gaming" it should've been here, but alas...
          "gui/apps/media-editing"
          "gui/apps/players"
          "gui/apps/streaming"

          "gui/themes"
          "gui/window-managers/hyprland"

          "user-preferences"

          "dev/ai"
        ];
        features = installation.features;
      };
    };
    imports = [
      ({ }: {
        opencode.agents = {
          brainstorm = {
            model = "opencode-go/deepseek-v4-pro";
            reasoningEffort = "high";
          };
          spec = {
            model = "opencode-go/deepseek-v4-pro";
            reasoningEffort = "high";
          };
          orchestrate = {
            model = "opencode-go/glm-5.3-flash";
            reasoningEffort = "low";
          };
          implementer = {
            model = "opencode-go/mimo-v2.6-pro";
          };
          implementer-flash = {
            model = "opencode-go/mimo-v2.6-flash";
          };
          reviewer = {
            model = "opencode-go/glm-5.3";
            reasoningEffort = "high";
          };
          explore = {
            model = "opencode-go/glm-5.3-flash";
            reasoningEffort = "low";
          };
        };
        opencode.plugins.octto.settings = {
          agents = {
            probe.model = "opencode/big-pickle";
            bootstrapper.model = "opencode/big-pickle";
          };
        };
      })
    ];
  };
}

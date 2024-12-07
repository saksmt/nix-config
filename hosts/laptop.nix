{ nixos-hardware, feature-definitions, ... }:
rec {
  imports = [
    nixos-hardware.nixosModules.asus-zephyrus-gu603h
    nixos-hardware.nixosModules.asus-battery

    (
      { pkgs, ... }:
      {
        users.users.smt.shell = pkgs.zsh;
        users.users.root.shell = pkgs.zsh;

        environment.systemPackages = with pkgs; [
          asusctl
          supergfxctl
        ];

        systemd.packages = [
          pkgs.supergfxctl
          pkgs.asusctl
        ];
        services.udev.packages = [
          pkgs.supergfxctl
          pkgs.asusctl
        ];
        services.udev.extraRules = ''
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl", GROUP="users"
        '';
        services.dbus.packages = [
          pkgs.supergfxctl
          pkgs.asusctl
        ];
        systemd.services.supergfxd.wantedBy = [ "multi-user.target" ];
        boot.supportedFilesystems = [ "ntfs" ];
        boot.loader.grub.gfxmodeEfi = "1280x800";
        services.xserver.deviceSection = ''Option "RegistryDwords" "EnableBrightnessControl=1"'';
        boot.kernelParams = [
          "i915.enable_psr=0"
        ];
        boot.kernel.sysctl = {
          "vm.swappiness" = 20;
        };
        hardware.asus.battery = {
          chargeUpto = 60;
          enableChargeUptoScript = true;
        };
      }
    )
  ];

  users.users.smt = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  };
  home-manager.users.smt = { pkgs, ... }: { };

  networking.hostName = "smt-laptop";
  networking.hosts = {
    "127.0.0.1" = [ "smt-laptop" ];
  };

  installation = {
    unstables =
      {
        from,
        unstable,
        copy-of,
        ...
      }:
      {
        jetbrains.idea-ultimate = from unstable;
        asusctl = from unstable;
        supergfxctl = from unstable;
        wrapOBS = from unstable;
        obs-studio-plugins = from unstable;

        unstable = copy-of unstable;
      };

    features = with feature-definitions; [
      GUI
      EFI
      HiDPI

      laptop

      gaming

      work
      dev.all
    ];

    package-sets = [
      "system"
      "runtime/docker"
      "runtime/jvm"

      "cli"
      "dev"

      "gui/setup/base"
      "gui/setup/sddm"
      "gui/setup/xorg"

      "gui/apps/gaming"
    ];

    home-manager = {
      enabled = true;

      installation = {
        # force management of zshrc and stuff through home-manager
        programs.zsh.enable = true;

        programs.git = {
          userName = "Kirill Saksin";
          userEmail = "smt@saksmt.dev";
        };

        package-sets = [
          "gui/apps/base"
          "gui/apps/dev"
          "gui/apps/im"
          # "gui/apps/gaming" it should've been here, but alas...
          "gui/apps/media-editing"
          "gui/apps/players"
          "gui/apps/streaming"

          "gui/setup/fonts"
          "gui/themes"
          "gui/window-managers/awesome"

          "user-preferences"
        ];
        features = installation.features;
      };
    };
  };
}

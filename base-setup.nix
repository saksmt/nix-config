{ config, pkgs, ... }:
with (import ./lib/env-functions.nix);

{ imports = [
    (whenHiDPI {
        i18n = {
            consoleFont = "ter-k32n";
        };
    })
    (whenNotHiDPI {
        i18n = {
            consoleFont = "ter-k16n";
        };
    })
    {
        nixpkgs.config.allowUnfree = true;
        boot.loader.grub.useOSProber = true;
        nixpkgs.config.glibc.installLocales = true;

        i18n = {
            consolePackages = with pkgs; [ terminus_font ];
            consoleKeyMap = "ruwin_alt_sh-UTF-8";
            defaultLocale = "ru_RU.UTF-8";
        };
        boot.earlyVconsoleSetup = true;

        nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 60d";
        };

        # Set your time zone.
        time.timeZone = "Europe/Moscow";

        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = with pkgs; [
          wget htop oh-my-zsh zsh git nfs-utils unzip exfat telnet libsecret
        ];

        programs.vim.defaultEditor = true;

        security.sudo.enable = true;
        security.sudo.wheelNeedsPassword = false;

        sound.enable = true;
        hardware.pulseaudio.enable = true;

        environment.shells = [ pkgs.zsh pkgs.bashInteractive ];

        users.users.root.shell = pkgs.zsh;

        programs.zsh.enable = true;
        programs.zsh.ohMyZsh.enable = true;
        programs.zsh.ohMyZsh.theme = "gentoo";
        programs.zsh.ohMyZsh.plugins = [ "git" "nix" "docker" ];

        # This value determines the NixOS release with which your system is to be
        # compatible, in order to avoid breaking some software such as database
        # servers. You should change this only after NixOS release notes say you
        # should.
        system.stateVersion = "19.09"; # Did you read the comment?
    }

    (whenLaptop {
        networking.networkmanager.enable = true;
        powerManagement.cpuFreqGovernor = "ondemand";
        services.upower.enable = true;
    })

    (whenNotLaptop {
        powerManagement.cpuFreqGovernor = "performance";
    })

    (whenEFI {
        # Use the systemd-boot EFI boot loader.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = false;
    })

    (whenNotEFI {
        boot.loader.grub.device = "/dev/sda";
    })

    (whenHomeLike {
        fileSystems."/mnt/nfs" = {
            device = "192.168.31.31:/data";
            fsType = "nfs";
            options = [ "defaults" "noauto" "nofail" "user" ];
        };
    })

    (whenHome {
        services.openssh.enable = true;
    })
]; }

uses: { config, pkgs, ... }:
with uses;

{ imports = [
    {
        nixpkgs.config.allowUnfree = true;

        programs.gnupg.agent.enable = true;
        programs.gnupg.agent.enableSSHSupport = true;

        environment.systemPackages = with pkgs; [
          wget 
          htop 
          oh-my-zsh 
          zsh
          git
          nfs-utils
          unzip
          exfat
          telnet
          libsecret
          bat
          fzf
          ripgrep
          fd
          moreutils
          lm_sensors
          iotop
          iftop
          bpytop
          gnupg
        ];
    }

    (whenNoX {
        programs.gnupg.agent.pinentryFlavor = "curses";
    })

    (whenNvidia {
        environment.systemPackages = with pkgs; [
            #nvtop
        ];
    })

    (whenLaptop {
        networking.networkmanager.enable = true;
        services.upower.enable = true;
    })

    (whenHome {
        services.openssh.enable = true;
    })
]; }

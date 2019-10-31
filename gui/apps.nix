{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenNotNoX { imports = [{

      environment.systemPackages = with pkgs; [
        firefox
        tdesktop
        pcmanfm
        deadbeef
#        skype
        qpdfview
        parcellite
        discord

        mpv
        smplayer
        
        gnome3.dconf
      ];

      nixpkgs.config.firefox = {
        ffmpegSupport = true;
        jre = true;
      };

      nixpkgs.config.mpv = {
        lameSupport = true;
        theoraSupport = true;
        x264Support = true;
      };

      services.gvfs.enable = true;
      services.udisks2.enable = true;
      environment.variables.GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];

      programs.dconf.enable = true;
    }

    (whenWorkLike {
        environment.systemPackages = [ pkgs.slack ];
    })

    (whenWork {
        environment.systemPackages = [ pkgs.gnome3.evolution ];
    })

    (whenHome {
        environment.systemPackages = [ pkgs.transmission-remote-gtk ];
    })

    (whenGuitar {
        environment.systemPackages = with pkgs; [ tuxguitar timidity ];
    })
]; }

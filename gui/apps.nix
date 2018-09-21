{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

{ imports = [{

      environment.systemPackages = with pkgs; [
        firefox
        tdesktop
        pcmanfm
        deadbeef
        skype
        qpdfview
        parcellite

        mpv
        smplayer
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

      services.gnome3.gvfs.enable = true;
      services.udisks2.enable = true;
      environment.variables.GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];
    }

    (whenWorkLike {
        environment.systemPackages = [ pkgs.slack ];
    })

    (whenWork {
        environment.systemPackages = [ pkgs.thunderbird ];
    })

    (whenHome {
        environment.systemPackages = [ pkgs.transmission-remote-gtk ];
    })
]; }

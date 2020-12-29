uses: { config, pkgs, ... }:
with uses;

{ imports = [
    (whenHiDPI {
        console.font = "ter-k32n";
    })
    (whenNotHiDPI {
        console.font = "ter-k16n";
    })
    {
        nixpkgs.config.glibc.installLocales = true;
        services.dbus.socketActivated = true;

        console = {
            earlySetup = true;
            packages = [ pkgs.terminus_font ];
            keyMap = "ruwin_alt_sh-UTF-8";
        };

        i18n = {
            defaultLocale = "ru_RU.UTF-8";
        };

        nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 60d";
        };

        time.timeZone = "Europe/Moscow";

        system.stateVersion = "20.09";
    }

    (whenLaptop {
        powerManagement.cpuFreqGovernor = "ondemand";
    })

    (whenNotLaptop {
        powerManagement.cpuFreqGovernor = "performance";
    })
]; }

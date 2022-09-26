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

        system.stateVersion = "22.05";

        nixpkgs.config.glibc.installLocales = true;

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
    }

    (whenLaptop {
        powerManagement.cpuFreqGovernor = "ondemand";
    })

    (whenNotLaptop {
        powerManagement.cpuFreqGovernor = "performance";
    })

    (whenPC {
        environment.systemPackages = [ pkgs.brightnessctl ];
        boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    })
]; }

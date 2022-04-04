uses: { config, pkgs, ... }:
with uses;

{ imports = [
    {
        sound.enable = true;
        hardware.pulseaudio.enable = true;
    }

    (whenBluetooth {
        hardware.bluetooth.settings = {
            General = {
                Enable = "Source,Sink,Media,Socket";
            };
        };

        hardware.pulseaudio = {
          extraModules = [ pkgs.pulseaudio-modules-bt ];
          extraConfig = ''
            load-module module-bluetooth-policy
            load-module module-bluetooth-discover
          '';
        };
    })

    (if (use "guitar" && use "bluetooth") then {
        hardware.pulseaudio.package = pkgs.pulseaudioFull.override {
            jackaudioSupport = true;
        };
    } else if (use "guitar") then {
        hardware.pulseaudio.package = pkgs.pulseaudio.override {
            jackaudioSupport = true;
        };
    } else if (use "bluetooth") then {
        hardware.pulseaudio.package = pkgs.pulseaudioFull;
    } else {})

    (whenGuitar {
        boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
    })
]; }

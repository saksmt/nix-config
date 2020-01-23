{ whenGuitar, ... } : { config, pkgs, ... }:

whenGuitar {
  hardware.pulseaudio.package = pkgs.pulseaudio.override { jackaudioSupport = true; };
  boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
}

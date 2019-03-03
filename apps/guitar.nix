{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenGuitar {
  hardware.pulseaudio.package = pkgs.pulseaudio.override { jackaudioSupport = true; };
  boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
}

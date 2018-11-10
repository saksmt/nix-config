{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenNotNoX {
  environment.systemPackages = [ pkgs.ffmpeg ];
}

{ whenNotNoX, ... } : { config, pkgs, ... }:

whenNotNoX {
  environment.systemPackages = [ pkgs.ffmpeg ];
}

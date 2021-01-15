_ : { config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ffmpeg-full ];
}

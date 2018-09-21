{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ffmpeg ];
}

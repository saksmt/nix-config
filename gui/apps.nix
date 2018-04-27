{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox
    thunderbird
    tdesktop
    pcmanfm
    deadbeef
    skype
    qpdfview

    mpv
    smplayer
  ];

  nixpkgs.config.firefox = {
    enableAdobeFlash = true;
    ffmpegSupport = true;
    jre = true;
  };

  nixpkgs.config.mpv = {
    lameSupport = true;
    theoraSupport = true;
    x264Support = true;
  };
}

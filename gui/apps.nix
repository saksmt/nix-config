{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

{
  environment.systemPackages = with pkgs; [
    firefox
    tdesktop
    pcmanfm
    deadbeef
    skype
    qpdfview
    parcellite

    mpv
    smplayer
  ];

  nixpkgs.config.firefox = {
    ffmpegSupport = true;
    jre = true;
  };

  nixpkgs.config.mpv = {
    lameSupport = true;
    theoraSupport = true;
    x264Support = true;
  };
} // whenWorkLike {
    environment.systemPackages = [ pkgs.slack ];
} // (whenWork {
    environment.systemPackages = [ pkgs.thunderbird ];
}) // (whenHome {
    environment.systemPackages = [ pkgs.transmission-remote-gtk ];
})

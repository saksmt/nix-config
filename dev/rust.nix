{ whenDev, ... } : { config, pkgs, ... }:

whenDev (let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
in {
  nixpkgs.overlays = [ moz_overlay ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    (latest.rustChannels.stable.rust.override { extensions = [ "rust-src" ]; })
    jetbrains.clion
  ];
})

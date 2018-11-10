{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenDev {
  environment.systemPackages = with pkgs; [
    gnumake
    gcc
    binutils
  ];
}

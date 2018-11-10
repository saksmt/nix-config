{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenMediaServer {
  services.plex.enable = true;
  services.nfs.enable = true;
}
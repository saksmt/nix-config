{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenNvidia {
  services.xserver.videoDrivers = [ "nvidia" ];
}

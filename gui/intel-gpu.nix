{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenIntelGpu {
    services.xserver.videoDrivers = [ "intel" ];
}

{ whenNvidia, ... } : { config, pkgs, ... }:

whenNvidia {
  services.xserver.videoDrivers = [ "nvidia" ];
}

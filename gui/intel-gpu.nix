{ whenIntelGpu, ... } : { config, pkgs, ... }:

whenIntelGpu {
    services.xserver.videoDrivers = [ "intel" ];
}

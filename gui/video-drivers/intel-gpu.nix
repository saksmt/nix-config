{ whenIntelGpu, ... } : _:

whenIntelGpu {
    services.xserver.videoDrivers = [ "intel" ];
}

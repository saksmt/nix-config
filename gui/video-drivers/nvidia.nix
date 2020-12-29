{ whenNvidia, ... } : _:

whenNvidia {
  services.xserver.videoDrivers = [ "nvidia" ];
}

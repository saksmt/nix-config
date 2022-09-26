{ whenMediaServer, ... }: { pkgs, ... }:

whenMediaServer {
    virtualisation.docker.enable = true;
    virtualisation.docker.enableOnBoot = true;

    environment.systemPackages = [ pkgs.docker-compose ];

    services.avahi.reflector = true;
    services.avahi.nssmdns = true;
    services.avahi.enable = true;
}

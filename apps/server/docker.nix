{ whenMediaServer, ... }: { pkgs, ... }:

whenMediaServer {
    virtualisation.docker.enable = true;
    virtualisation.docker.enableOnBoot = true;

    environment.systemPackages = [ pkgs.docker_compose ];
}

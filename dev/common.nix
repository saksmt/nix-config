{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenDev {
  imports = [ 
#    (whenNotNoX { environment.systemPackages = [ pkgs.postman ]; })

    {
      environment.systemPackages = with pkgs; [
        docker_compose
        gitAndTools.tig
        jq
      ];

      virtualisation.docker.enable = true;
      virtualisation.docker.enableOnBoot = true;
    }
  ];
}

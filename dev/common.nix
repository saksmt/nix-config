{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenDev {
  imports = [ 
#    (whenNotNoX { environment.systemPackages = [ pkgs.postman ]; })

    (whenNotNoX { environment.systemPackages = with pkgs; [
        vscode
        freemind
    ]; })

    {
      environment.systemPackages = with pkgs; [
        docker_compose
        gitAndTools.tig
        jq
        httpie
        jo
        graphviz
      ];

      virtualisation.docker.enable = true;
      virtualisation.docker.enableOnBoot = true;
    }
  ];
}

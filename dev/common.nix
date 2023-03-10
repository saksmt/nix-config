{ whenDev, whenNotNoX, ... } : { config, pkgs, ... }:

whenDev {
  imports = [

    (whenNotNoX { environment.systemPackages = with pkgs; [
        vscode
        freemind
        appflowy
    ]; })

    {
      environment.systemPackages = with pkgs; [
        docker-compose
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

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    docker_compose
    gitAndTools.tig
    jq
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
}

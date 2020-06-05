{ whenDev, ... }: { config, pkgs, ... }:

whenDev {
  environment.systemPackages = with pkgs; [
    kubectl
  ];
}

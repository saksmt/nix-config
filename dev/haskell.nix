{ whenDev, ... } : { config, pkgs, ... }:

whenDev {
  environment.systemPackages = with pkgs; [ stack ];
}

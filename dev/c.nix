{ whenDev, ... } : { config, pkgs, ... }:

whenDev {
  environment.systemPackages = with pkgs; [
    gnumake
    gcc
    binutils
  ];
}

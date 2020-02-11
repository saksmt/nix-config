{ whenDev, ... } : { config, pkgs, ... }:

whenDev {
  environment.systemPackages = [ pkgs.rustc pkgs.cargo ];
}

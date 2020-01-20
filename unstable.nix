{ config, pkgs, ... }:

let unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixpkgs-unstable.tar.gz;
in {
  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball { config = config.nixpkgs.config; };
    };
  };
}

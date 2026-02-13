args@{ pkgs, ... }:
{
  os-rebuild = pkgs.callPackage ./os-rebuild.nix { };
  home-rebuild = pkgs.callPackage ./home-rebuild.nix { };
  build-images = import ./iso args;
}

args@{ pkgs, ... }:
{
  os-rebuild = pkgs.callPackage ./os-rebuild.nix { };
  home-rebuild = pkgs.callPackage ./home-rebuild.nix { };
  mcp-wrapper = pkgs.callPackage ./mcp-wrapper.nix { };
  json-confd = pkgs.callPackage ./json-confd.nix { };
  build-images = import ./iso args;
}

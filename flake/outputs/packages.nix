{ nixpkgs, utils, ... }:
isoConfigurations:
(utils.lib.eachDefaultSystem (
  system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages = import ../../custom-packages pkgs // {
      images = builtins.mapAttrs (_: v: v.image.iso) isoConfigurations.${system};
    };
  }
)).packages

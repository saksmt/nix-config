globalScope@{ conf, ... }: stdNix@{ config, pkgs, ... }:

with builtins;

let

  overlays = map (name: let
    path = ../. + "/overlays/${name}.nix";
  in import path) conf.overlays;

  applyOverlay = prev@{ originalPkgs, currentPkgs, currentOverrides, overlay }: let 
    overlayOverrides = overlay (globalScope // {
      inherit originalPkgs currentPkgs currentOverrides;
    }) stdNix;
  in rec {
    currentOverrides = prev.currentOverrides // overlayOverrides;
    currentPkgs = originalPkgs // currentOverrides;
    inherit originalPkgs;
  };

  allOverrides = foldl' (previousOverlays: currentOverlay:
    rootArgs: applyOverlay ((previousOverlays rootArgs) // { overlay = currentOverlay; })
  ) (id: id) overlays;

in {
  nixpkgs.config.packageOverrides = pkgs: (allOverrides {
    originalPkgs = pkgs;
    currentPkgs = pkgs;
    currentOverrides = {};
  }).currentOverrides;
}


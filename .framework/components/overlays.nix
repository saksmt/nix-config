globalScope@{ conf, ... }: stdNix@{ config, pkgs, lib, ... }:

with builtins;

let

  recMergeIf = needMerge: l: r:
    if isAttrs l && isAttrs r && needMerge l r then
      l // lib.mapAttrs (rn: rv:
        if hasAttr rn l then
          recMergeIf needMerge (getAttr rn l) rv
        else
          rv
      ) r
    else r
  ;

  mergePackageSets = recMergeIf (_: r: !lib.isDerivation r);

  overlays = map (name: let
    path = ../. + "/overlays/${name}.nix";
  in import path) conf.overlays;

  applyOverlay = prev@{ originalPkgs, currentPkgs, currentOverrides, overlay }: let
    overlayOverrides = overlay (globalScope // {
      inherit originalPkgs currentPkgs currentOverrides;
    }) stdNix;
  in rec {
    currentOverrides = mergePackageSets prev.currentOverrides overlayOverrides;
    currentPkgs = mergePackageSets originalPkgs currentOverrides;
    inherit originalPkgs;
  };

  allOverrides = foldl' (previousOverlays: currentOverlay:
    rootArgs: applyOverlay ((previousOverlays rootArgs) // { overlay = currentOverlay; })
  ) lib.id overlays;

in {
  nixConfig.nixpkgs.overlays = [ (
    self: super:
      let
        result = (allOverrides {
          originalPkgs = super;
          currentPkgs = super;
          currentOverrides = {};
        }).currentOverrides;
      in result
  ) ];

}

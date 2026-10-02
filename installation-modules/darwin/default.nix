{ self, ... }@inputs:
with (import (self.outPath + "/installation-modules/lib.nix"));

includeAllRelative self [

  "/installation-modules/darwin/polyfils.nix"
  "/installation-modules/darwin/system.nix"

  "/installation-modules/darwin/external-modules.nix"

  "/installation-modules/common/features.nix"
  "/installation-modules/common/nix-setup.nix"

  # hack, replace with some custom jail wrapper and do away with bublewrap dependent jail-nix
  "/installation-modules/darwin/jail-stub.nix"

  "/installation-modules/common/overlays.nix"
  "/installation-modules/common/package-sets.nix"
  "/installation-modules/common/unstables.nix"

  "/installation-modules/common/passthrou-nixos.nix"

  "/installation-modules/darwin/home-manager.nix"
] inputs

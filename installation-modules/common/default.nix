{ self, ... }@inputs:
with (import (self.outPath + "/installation-modules/lib.nix"));

includeAllRelative self [
  "/installation-modules/common/features.nix"
  "/installation-modules/common/nix-setup.nix"
  "/installation-modules/common/overlays.nix"
  "/installation-modules/common/package-sets.nix"
  "/installation-modules/common/unstables.nix"

  "/installation-modules/common/passthrou-nixos.nix"
] inputs

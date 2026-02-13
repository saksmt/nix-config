{ self, ... }@inputs:
with (import (self.outPath + "/installation-modules/lib.nix"));

includeAllRelative self [

  "/installation-modules/nixos/hm-adapter.nix"

  "/installation-modules/nixos/external-modules.nix"
  "/installation-modules/common"
  "/installation-modules/nixos/home-manager.nix"

  "/installation-modules/iso/base-image-builders.nix"
] inputs

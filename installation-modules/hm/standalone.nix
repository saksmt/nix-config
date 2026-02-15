{ self, ... }@inputs:
with (import (self.outPath + "/installation-modules/lib.nix"));

# this should not be used when including HM as part of nixos
includeAllRelative self [
  "/installation-modules/hm/save-flake-args.nix"
  "/installation-modules/hm/hm-adapter.nix"
  "/installation-modules/hm/hm-setup.nix"
  "/installation-modules/hm/hm-system.nix"
  "/installation-modules/hm/hm-nixgl.nix"
  "/installation-modules/hm/external-modules.nix"

  "/installation-modules/common"
] inputs

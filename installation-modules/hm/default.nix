{ self, ... }@inputs:
with (import (self.outPath + "/installation-modules/lib.nix"));

# this should not be used when including HM as part of nixos
includeAllRelative self [
  "/installation-modules/hm/hm-adapter.nix"
  "/installation-modules/hm/hm-setup.nix"

  "/installation-modules/common"
] inputs

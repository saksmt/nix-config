{
  nix-features,
  nixpkgs,
  self,
  ...
}:
let
  lib = nix-features.nixLibs.default nixpkgs;
  feature-definitions =
    let
      uncompiled = import (self.outPath + "/feature-definitions.nix");
    in
    lib.define-features-or-throw uncompiled;
in
{
  recipe-args = {
    inherit feature-definitions;
  };

  process-recipe =
    {
      installation ? { },
      ...
    }:
    {
      module-args = {
        features = lib.assign-features feature-definitions (installation.features or [ ]);
      };
    };
}

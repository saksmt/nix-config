{self, ...}@inputs: {
  process-recipe = _: {
    modules = [
      (
        {
          config,
          pkgs,
          lib,
          ...
        }@nixpkgs:
        {
          nixpkgs.overlays = import (self.outPath + "/overlays") inputs nixpkgs;
        }
      )
    ];
  };
}

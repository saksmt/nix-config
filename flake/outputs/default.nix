{
  self,
  ...
}@resolvedInputs:
let
  installation-module-lib = import (self.outPath + "/installation-modules/lib.nix");
  recipe-loader = installation-module-lib.loader {
    self = self;
    module-args = resolvedInputs // {
      nix-polyfils = import ../../lib/nix-polyfils;
    };
  };

  outputs = rec {

    templates = {
      rust-base = {
        path = ./templates/rust-base;
        description = "Base rust template (flake, toolchain, empty rustfmt)";
      };
    };

    repl = (import ./repl.nix) resolvedInputs outputs;

    nixosConfigurations = (import ./nixos.nix) recipe-loader;
    homeConfigurations = (import ./home.nix) recipe-loader;
    darwinConfigurations = (import ./darwin.nix) recipe-loader;
    isoConfigurations = (import ./iso.nix) resolvedInputs recipe-loader;

    packages = (import ./packages.nix) resolvedInputs isoConfigurations;
  };
in
outputs

{
  description = "";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
      ...
    }:
    {
      nixLibs.default = import ./src/lib;
      nixLibs._PRIVATE = import ./src/lib/private.nix;

      checks = utils.lib.eachDefaultSystem (system: {
        ${system} =
          nixpkgs.legacyPackages.${system}.runCommand "tests"
            {
              nativeBuildInputs = [ nixpkgs.legacyPackages.${system}.nix-unit ];
            }
            ''
              export HOME="$(realpath .)"
              nix-unit --eval-store "$HOME" \
                --extra-experimental-features flakes \
                --override-input nixpkgs ${nixpkgs} \
                --flake ${self}#tests
              touch $out
            '';
      });
      tests =
        let
          test =
            body:
            body
            // {
              THIS_IS_MARKER_FOR_TESTS = "TEST";
            };
          flattenTests =
            current-path: tests:
            if (builtins.isAttrs tests) then
              if ((tests.THIS_IS_MARKER_FOR_TESTS or "") == "TEST") then
                {
                  "test: ${builtins.concatStringsSep " " current-path}" = builtins.removeAttrs tests [
                    "THIS_IS_MARKER_FOR_TESTS"
                  ];
                }
              else
                nixpkgs.lib.attrsets.foldlAttrs (
                  acc: name: test:
                  acc // (flattenTests (current-path ++ [ name ]) test)
                ) { } tests
            else
              { };
        in
        flattenTests [ ] (import ./tests (nixpkgs // { inherit test; }));
    };
}

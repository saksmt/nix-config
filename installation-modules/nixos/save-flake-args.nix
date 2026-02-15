args: {
  process-recipe =
    {
      installation ? { },
      ...
    }:
    let
      keep-flake = installation.keep-flake or true;
    in
    {
      module-args = {
        flake-inputs = args;
      };
      modules =
        if keep-flake then
          [
            (
              {
                flake-inputs,
                lib,
                pkgs,
                ...
              }:
              let
                all-inputs =
                  inputs:
                  builtins.concatMap (
                    input: [ input ] ++ (all-inputs (input.inputs or { }))
                  ) (builtins.attrValues inputs);
                refs = pkgs.writeText "flake-inputs" (
                  builtins.concatStringsSep "\n" (
                    lib.unique (all-inputs (builtins.removeAttrs flake-inputs [ "nix-hm-adapter" ]))
                  )
                );
              in
              {
                system.extraDependencies = [ refs ];
              }
            )
          ]
        else
          [ ];
    };
}

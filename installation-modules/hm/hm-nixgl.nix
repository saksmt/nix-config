{ nixgl, ... }:
{
  process-recipe =
    {
      installation ? { },
      ...
    }:
    let
      nix-gl = {
        enabled = false;
        wrapper-script-prefix = null;
      }
      // (installation.nix-gl or { });
    in
    {
      modules =
        if (nix-gl.enabled && !(builtins.isFunction nix-gl.wrapper-script-prefix)) then
          (builtins.throw "NixGL feature enabled, but no wrapper script prefix provided")
        else
          [
            (
              { pkgs, lib, ... }:
              {
                nixpkgs.overlays = [
                  (self: super: {
                    nix-gl-wrap =
                      if nix-gl.enabled then
                        (
                          pkg:
                          (pkg.overrideAttrs (old: {
                            name = "nixGL-${pkg.name}";

                            # Make sure this is false for the wrapper derivation, so nix doesn't expect
                            # a new debug output to be produced. We won't be producing any debug info
                            # for the original package.
                            separateDebugInfo = false;
                            nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pkgs.makeWrapper ];
                            buildCommand = ''
                              set -eo pipefail

                              ${
                                # Heavily inspired by https://stackoverflow.com/a/68523368/6259505
                                lib.concatStringsSep "\n" (
                                  map (outputName: ''
                                    echo "Copying output ${outputName}"
                                    set -x
                                    cp -rs --no-preserve=mode "${pkg.${outputName}}" "''$${outputName}"
                                    set +x
                                  '') (old.outputs or [ "out" ])
                                )
                              }

                              rm -rf $out/bin/*
                              shopt -s nullglob # Prevent loop from running if no files
                              for file in ${pkg.out}/bin/*; do
                                local prog="$(basename "$file")"
                                makeWrapper \
                                  "${nix-gl.wrapper-script-prefix super}" \
                                  "$out/bin/$prog" \
                                  --argv0 "$prog" \
                                  --add-flags "$file"
                              done

                              # If .desktop files refer to the old package, replace the references
                              for dsk in "$out/share/applications"/*.desktop ; do
                                if ! grep -q "${pkg.out}" "$dsk"; then
                                  continue
                                fi
                                src="$(readlink "$dsk")"
                                rm "$dsk"
                                sed "s|${pkg.out}|$out|g" "$src" > "$dsk"
                              done

                              shopt -u nullglob # Revert nullglob back to its normal default state
                            '';
                          }))
                        )
                      else
                        (id: id);
                  })
                ];
              }
            )

            (_: { nixpkgs.overlays = [ nixgl.overlays.default ]; })
          ];
    };
}

{
  nix-unstables,
  nixpkgs-unstable,
  nixpkgs-master,
  ...
}:
let
  ulib = nix-unstables.libs.default;
  source =
    x:
    if builtins.isFunction x then
      ulib.define-source { PKG_DEPENDENT = v: ulib.define-source (x v); }
    else
      ulib.define-source x;
  default-unstable-sources =
    { source }:
    {
      unstable = source (
        { pkgs, ... }:
        import nixpkgs-unstable {
          system = pkgs.system;
          config.allowUnfree = true;
        }
      );
      master = source (
        { pkgs, ... }:
        import nixpkgs-master {
          system = pkgs.system;
          config.allowUnfree = true;
        }
      );
    };
in
{
  process-recipe =
    {
      installation ? { },
      ...
    }:
    {
      modules =
        let
          sources =
            ((installation.unstable-sources or (_: { })) { inherit source; })
            // (default-unstable-sources { inherit source; });
          unstables = (installation.unstables or (_: { }));
        in
        [
          (
            {
              config,
              lib,
              pkgs,
              nixpkgs,
              ...
            }@nixpkgsP:
            {
              nixpkgs.overlays =
                let
                  finalSources = ulib.make-source-tree (
                    ulib.mapUninitTree (
                      path: value: if value ? PKG_DEPENDENT then value.PKG_DEPENDENT nixpkgsP else value
                    ) sources
                  );
                  compiledConfig = ulib.compile-unstables-config finalSources unstables;
                in
                [ (ulib.overlay compiledConfig) ];
            }
          )
        ];
    };
}

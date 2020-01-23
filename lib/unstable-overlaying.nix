uses: overrides: { config, pkgs, ... }:
with (import ./uses/env-functions.nix);

{
  nixpkgs.config = {
    packageOverrides = pkgs: let
      cfg      = { config = config.nixpkgs.config // { packageOverrides = _: {}; }; };
      unstable = import uses.env.unstablePath cfg;
      forked   = import uses.env.forkedPath cfg;
    in {
      inherit unstable forked;
    } // (overrides unstable forked);
  };
}

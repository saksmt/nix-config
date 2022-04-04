{ conf, ... } : stdNix@{ config, ... }:

with conf;

let
  cfg       = { config = config.nixpkgs.config // { packageOverrides = _: {}; }; };
  unstable  = (import unstablePath) cfg;
  forked    = (import forkedPath) cfg;
  overrides = conf.unstables;
in {
  inherit unstable forked;
} // (overrides unstable forked)


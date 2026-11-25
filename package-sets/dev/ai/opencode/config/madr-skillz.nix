{
  features,
  lib,
  flake-inputs,
  ...
}:
with features;
let
  forFeature = feature: lib.optionalAttrs feature.isEnabled;
in
forFeature dev.common {
  opencode.skills.rootDirectories = ["${flake-inputs.madr-skillz}/skills"];
}

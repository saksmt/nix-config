{
  features,
  lib,
  ...
}:
with features;
let
  forFeature = feature: lib.optionalAttrs feature.isEnabled;
  # todo: mem0
in
forFeature dev.common {
  opencode.confd."000-shared/plugins/mem" = { };
}

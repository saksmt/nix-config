{
  features,
  lib,
  ...
}:
with features;
let
  forFeature = feature: lib.optionalAttrs feature.isEnabled;
in
forFeature dev.common {
  opencode.confd."000-shared/plugins" = {
    plugin = [
      "@gotgenes/opencode-agent-identity@3.1.1"
      [
        "@plannotator/opencode@0.27.21"
        { workflow = "user-managed"; }
      ]
    ];
  };
}

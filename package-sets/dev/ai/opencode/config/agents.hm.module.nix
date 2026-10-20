{
  features,
  lib,
  config,
  pkgs,
  ...
}:
with features;
let
  forFeature = feature: lib.optionalAttrs feature.isEnabled;
  jsonFormat = pkgs.formats.json { };
in
forFeature dev.common {
  options.opencode.agents = lib.mkOption {
    type = lib.types.attrsOf jsonFormat.type;
  };

  config.opencode.confd."000-shared/agent-models" = {
    agent = config.opencode.agents;
  };
}

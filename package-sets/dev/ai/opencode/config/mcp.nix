{
  features,
  lib,
  config,
  ...
}:
with features;
let
  forFeature = feature: lib.optionalAttrs feature.isEnabled;
in
forFeature dev.common {
  opencode.confd."000-shared/mcp" = {
    mcp = {
      grep-app = {
        type = "remote";
        url = "https://mcp.grep.app";
        enabled = true;
      };
      context7 = {
        type = "remote";
        url = "https://mcp.context7.com/mcp";
        enabled = true;
      };
    };
  };
}
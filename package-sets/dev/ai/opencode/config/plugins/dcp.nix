{
  features,
  config,
  pkgs,
  lib,
  ...
}:
with features;
let
  forFeature = feature: lib.optionalAttrs feature.isEnabled;
  merge = builtins.foldl' (a: b: a // b) { };
  jsonFormat = pkgs.formats.json { };
  cfg = config.opencode.plugins.dcp;
  defaultConfiguration = {
    enabled = true;
    pruneNotification = "minimal";
    pruneNotificationType = "toast";
    commands = {
      enabled = true;
      #todo add occto/planner
      protectedTools = [ ];
    };
    compress = {
      mode = "range";
      #todo maybe change later
      permission = "ask";
      showCompression = false;
      maxContextLimit = "90%";
      minContextLimit = "65%";
      #todo add occto/planner
      protectedTools = [ ];
    };
    strategies = {
      deduplication.enabled = true;
      purgeErrors.enabled = true;
    };
  };
in
{
  options.opencode.plugins.dcp = {
    enable = lib.mkEnableOption "dcp" // {
      default = true;
    };
    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = "opencode-dcp configuration";
    };
  };
  config = forFeature dev.common {
    opencode.confd."000-shared/plugins/dcp" = lib.mkIf cfg.enable {
      plugin = [ "@tarquinen/opencode-dcp@3.1.15" ];
    };

    xdg.configFile."opencode/dcp.jsonc" = lib.mkIf cfg.enable {
      source = jsonFormat.generate "dcp.json" (
        lib.attrsets.recursiveUpdate defaultConfiguration cfg.settings
      );
    };
  };
}

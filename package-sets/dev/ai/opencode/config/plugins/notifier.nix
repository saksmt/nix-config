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
  cfg = config.opencode.plugins.notifier;
  jsonFormat = pkgs.formats.json { };
  defaultConfiguration = {
    sound = true;
    notification = true;
    timeout = 15;
    showProjectName = true;
    showSessionTitle = true;
    showIcon = true;
    suppressWhenFocused = false;
    enableOnDesktop = true;
    linux.grouping = true;
  };
in
{
  options.opencode.plugins.notifier = {
    enable = lib.mkEnableOption "notifier" // {
      default = true;
    };
    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = "opencode notifier configuration";
    };
  };

  config = forFeature dev.common {
    opencode.confd."000-shared/plugins/notifier" = lib.mkIf cfg.enable {
      plugin = [ "@mohak34/opencode-notifier@0.2.4" ];
    };

    xdg.configFile."opencode/opencode-notifier.json".source = lib.mkIf cfg.enable (
      jsonFormat.generate "opencode-notifier.json" (
        lib.attrsets.recursiveUpdate defaultConfiguration cfg.settings
      )
    );
  };
}

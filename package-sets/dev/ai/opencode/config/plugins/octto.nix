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
  cfg = config.opencode.plugins.octto;
  jsonFormat = pkgs.formats.json { };
  defaultConfig = {
    port = 0;
    agents.octto.disable = true;
  };
in
{
  options.opencode.plugins.octto = {
    enable = lib.mkEnableOption "octto" // {
      default = true;
    };
    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = "opencode octto configuration";
    };
  };
  config = forFeature dev.common {
    opencode.confd."000-shared/plugins/octto" = lib.mkIf cfg.enable {
      plugin = [ "octto@0.3.1" ];
      # disabling default octto agent to use as a part of workflow instead of a dedicated agent
      agent.octto.disable = true;
      agent.octto.hidden = true;
    };
    xdg.configFile."opencode/octto.json".source = lib.mkIf cfg.enable (
      jsonFormat.generate "octto.json" (lib.attrsets.recursiveUpdate defaultConfig cfg.settings)
    );

    programs.git.ignores = lib.mkIf cfg.enable [".octto/"];
  };
}

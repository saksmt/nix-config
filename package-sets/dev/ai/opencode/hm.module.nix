{
  features,
  config,
  pkgs,
  lib,
  ...
}:
with features;
let
  jsonFormat = pkgs.formats.json { };
  toFileValue =
    name: cfg:
    if lib.isString cfg then
      { text = cfg; }
    else
      {
        source = if (lib.isPath cfg) || (lib.isDerivation cfg) then cfg else (jsonFormat.generate name cfg);
      };
in
if dev.common.isEnabled then
  {

    options.opencode = {
      confd = lib.mkOption {
        type = with lib; types.attrsOf (types.either jsonFormat.type (types.either types.path types.str));
        default = { };
        description = "Attr set with file name as key and either path, raw string or json as value";
      };

      tui = lib.mkOption {
        type = jsonFormat.type;
        default = { };
        description = "opencode TUI configuration";
      };
    };

    config = {
      module-for = [
        "hm"
      ];

      home.file.".config/opencode/opencode.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/opencode/opencode.generated.json";

      xdg.configFile =
        (lib.mapAttrs' (
          name: file:
          let
            path = "opencode/conf.d/${if lib.hasSuffix ".json" name then name else "${name}.json"}";
          in
          lib.nameValuePair path (toFileValue (builtins.baseNameOf path) file)
        ) config.opencode.confd)
        // {
          "opencode/tui.json" = toFileValue "tui.json" config.opencode.tui;
        };
    };
  }
else
  { }

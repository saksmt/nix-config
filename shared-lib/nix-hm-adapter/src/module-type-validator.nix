system-type:
{
  config,
  options,
  lib,
  ...
}:
let
  contramapCheck =
    f: typeDef:
    typeDef
    // {
      check = v: typeDef.check (f v);
    };
  caseInsensitiveEnum =
    alternatives:
    contramapCheck lib.strings.toLower (lib.types.enum (builtins.map lib.strings.toLower alternatives));
in
{
  options.module-for =
    with lib;
    mkOption {
      default = [ ];
      # dealias
      apply = builtins.map (v: if v == "home-manager" then "hm" else v);
      type = types.listOf (caseInsensitiveEnum [
        "hm"
        "home-manager"
        "nixos"
      ]);
    };
  config.assertions = [
    (
      let
        definitions = builtins.filter (
          { value, ... }: builtins.length value > 0
        ) options.module-for.definitionsWithLocations;
        pseudoCheckToForceFullResolution =
          (builtins.elem system-type config.module-for) || ((builtins.length definitions) == 0);
        actualCheck = builtins.all checkLocation definitions;
        checkLocation = { file, value, ... }: builtins.elem system-type value;
        failedLocations = builtins.map (v: builtins.toJSON (builtins.removeAttrs v [ ])) (
          builtins.filter (v: !checkLocation v) definitions
        );
      in
      {
        assertion = pseudoCheckToForceFullResolution && actualCheck;
        message = "Included modules that does not support ${system-type} module type: ${builtins.concatStringsSep "\n" failedLocations}";
      }
    )
  ];
}

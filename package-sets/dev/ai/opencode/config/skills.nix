{
  features,
  lib,
  config,
  ...
}:
with features;
let
  forFeature = feature: lib.optionalAttrs feature.isEnabled;
  cfg = config.opencode.skills;
in
forFeature dev.common {
  options.opencode.skills.rootDirectories = lib.mkOption {
    type = lib.types.listOf (lib.types.pathWith { });
  };

  config.home.file = builtins.foldl' (a: b: a // b) { } (
    builtins.concatMap (
      skillRoot:
      builtins.map (skill: {
        ".config/opencode/skills/${skill}/SKILL.md".source = "${skillRoot}/${skill}/SKILL.md";
      }) (builtins.attrNames (builtins.readDir skillRoot))
    ) cfg.rootDirectories
  );
}

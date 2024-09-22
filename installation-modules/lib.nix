let
  collectFields =
    field-name: attr-sets:
    builtins.map (builtins.getAttr field-name) (
      builtins.filter (builtins.hasAttr field-name) attr-sets
    );
  concatAttrs = builtins.foldl' (a: b: a // b) { };
  ## version of <*>
  # applyF :: [a -> b] -> a -> [b]
  applyF = functions: value: builtins.map (f: f value) functions;
  mkRecipe = args: process: {
    recipe-args = args;
    process-recipe = process;
  };
  mkConfigurationInstance = args: modules: {
    module-args = args;
    inherit modules;
  };
in
rec {
  ### Include relative to flake root
  ## includeAllRelative :: Flake -> PathLike[] -> InstallationModule
  includeAllRelative =
    self: root-relative-paths: includeAll (builtins.map (it: self.outPath + it) root-relative-paths);

  ## includeAll :: PathLike[] -> InstallationModule
  includeAll = paths: aggregate (builtins.map (import) paths);

  ## aggregate :: InstallationModule[] -> InstallationModule
  aggregate =
    installation-modules: inputs:
    let
      recipe-processors = applyF installation-modules inputs;
      recipe-args = concatAttrs (collectFields "recipe-args" recipe-processors);
      process-recipe-functions = collectFields "process-recipe" recipe-processors;
      process-recipe =
        out:
        let
          configuration-instance = applyF process-recipe-functions out;
          module-args = concatAttrs (collectFields "module-args" configuration-instance);
          modules = builtins.concatLists (collectFields "modules" configuration-instance);
        in
        mkConfigurationInstance module-args modules;
    in
    mkRecipe recipe-args process-recipe;

  ## apply :: FlakeInputs -> InstallationModule -> InstallationRecipe -> ConfigurationInstance
  apply =
    inputs: installation-module: installation-recipe:
    let
      recipe-processor = installation-module inputs;
      configuration-instance = recipe-processor.process-recipe (
        installation-recipe (inputs // recipe-processor.recipe-args)
      );
    in
    configuration-instance;
}

/**
 * Configuration instance to pass to lib.nixosSystem or lib.homeManager
 */
type ConfigurationInstance = {
    'module-args': ModuleArgs;
    modules: NixOsModule[]
};

type NixOsModule = symbol;
type ModuleArgs = Record<string, any>
type FlakeInputs = Record<string, any>

type InstallationDescription = Record<string, any>;
type InstallationRecipeInputs = FlakeInputs & ModuleArgs;
type InstallationRecipe = (_: InstallationRecipeInputs) => InstallationDescription;

type InstallationRecipeProcessor = {
    /** Arguments to pass to InstallationRecipe */
    'recipe-args': ModuleArgs;
    'process-recipe': (_: InstallationRecipe) => ConfigurationInstance
};
type InstallationModule = (_: FlakeInputs) => InstallationRecipeProcessor

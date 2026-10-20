let
  defineOpts =
    lib: with lib; {
      install.packages = mkOption {
        description = "Packages to add to environment.systemPackages or home.packages";
        default = [ ];
        type = types.listOf types.package;
      };
      install.sessionVariables = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Session variables to set via environment.sessionVariables or home.sessionVariables";
      };
    };
in
{
  nixosModule =
    { config, lib, ... }:
    {
      options = defineOpts lib;
      config.environment.systemPackages = config.install.packages;
      config.environment.sessionVariables = config.install.sessionVariables;
    };
  darwinModule =
      { config, lib, ... }:
      {
        options = defineOpts lib;
        config.environment.systemPackages = config.install.packages;
        config.environment.sessionVariables = config.install.sessionVariables;
      };
  homeManagerModule =
    { config, lib, ... }:
    {
      options = defineOpts lib;
      config.home.packages = config.install.packages;
      config.home.sessionVariables = config.install.sessionVariables;
    };
}

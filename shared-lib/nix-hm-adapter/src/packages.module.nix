let
  defineOpts =
    lib: with lib; {
      install.packages = mkOption {
        description = "Packages to add to environment.systemPackages or home.packages";
        default = [ ];
        type = types.listOf types.package;
      };
    };
in
{
  nixosModule =
    { config, lib, ... }:
    {
      options = defineOpts lib;
      config.environment.systemPackages = config.install.packages;
    };
  homeManagerModule =
    { config, lib, ... }:
    {
      options = defineOpts lib;
      config.home.packages = config.install.packages;
    };
}

{
  nixosModule =
    {
      config,
      lib,
      ...
    }:
    {
    };
  homeManagerModule =
    { config, lib, ... }:
    {
      options.fonts.packages =
        with lib;
        mkOption {
          default = [ ];
          type = types.listOf types.package;
          description = "Fonts to install";
        };
      config.home.packages = config.fonts.packages;
    };
}

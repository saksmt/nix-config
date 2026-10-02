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

  darwinModule =
    { lib, ... }:
    {
      options.fonts.fontconfig = with lib;
        mkOption {
          default = {};
          type = types.attrs;
          description = "Fontconfig stub for darwin - noop";
        };
    };
}

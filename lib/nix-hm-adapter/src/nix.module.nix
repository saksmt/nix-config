{
  nixosModule =
    { config, lib, ... }:
    {
      options.nix.gc.frequency =
        with lib;
        mkOption {
          type = types.str;
          default = "weekly";
        };
      config.nix.gc.dates = config.nix.gc.frequency;
    };
  homeManagerModule =
    { config, lib, ... }:
    {
      options.nix.gc.dates =
        with lib;
        mkOption {
          type = types.str;
          default = "weekly";
        };
      config.nix.gc.frequency = config.nix.gc.dates;
    };
}

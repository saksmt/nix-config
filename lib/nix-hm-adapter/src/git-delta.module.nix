{
  nixosModule =
    { config, lib, ... }:
    {
      options.programs.git.delta = with lib; {
        enable = mkOption {
          type = types.bool;
          apply = v: warnIf v "programs.git.delta is not supported as a nixos module yet!" v;
          default = false;
        };
      };
      options.programs.delta = with lib; {
        enableGitIntegration = mkOption {
          type = types.bool;
          apply = v: warnIf v "programs.delta is not supported as a nixos module yet!" v;
          default = false;
        };
      };
    };
  homeManagerModule =
    { config, lib, ... }:
    {
    };
}

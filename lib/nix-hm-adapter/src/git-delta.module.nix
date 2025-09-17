{
  nixosModule =
    { config, lib, ... }:
    let
      unimplementedEnableFlag = with lib; {
        enable = mkOption {
          type = types.bool;
          apply = v: warnIf v "programs.git.delta is not supported as a nixos module yet!" v;
          default = false;
        };
      };
    in
    {
      options.programs.git.delta = unimplementedEnableFlag;
    };
  homeManagerModule =
    { config, lib, ... }:
    {
    };
}

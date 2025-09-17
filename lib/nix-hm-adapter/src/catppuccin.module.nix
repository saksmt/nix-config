{
  nixosModule =
    { config, lib, ... }:
    let
      todoFlag =
        name: with lib; {
          "${name}" = {
            enable = mkOption {
              type = types.bool;
              apply = v: warnIf v "catppuccin for ${name} is not supported as a nixos module yet!" v;
              default = false;
            };
          };
        };
    in
    {
      options.catppuccin = todoFlag "btop" // todoFlag "bat" // todoFlag "fzf" // todoFlag "delta" // todoFlag "lazygit";
    };
  homeManagerModule =
    { config, lib, ... }:
    {
    };
}

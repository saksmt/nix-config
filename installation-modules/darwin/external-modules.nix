{ catppuccin, nix-index-database, ... }:
{
  process-recipe = _: {
    modules = [
      catppuccin.darwinModules.catppuccin
      nix-index-database.darwinModules.default

      ./nixos-modules
    ];
  };
}

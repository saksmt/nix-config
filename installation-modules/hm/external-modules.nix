{ catppuccin, awesome-iwm, nix-index-database, ... }:
{
  process-recipe = _: {
    modules = [
      catppuccin.homeModules.catppuccin
      awesome-iwm.homeModules.awesome-iwm
      nix-index-database.homeModules.default
    ];
  };
}

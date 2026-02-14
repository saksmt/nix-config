{ catppuccin, awesome-iwm, nix-index-database, ... }:
{
  process-recipe = _: {
    modules = [
      catppuccin.nixosModules.catppuccin
      awesome-iwm.nixosModules.awesome-iwm
      nix-index-database.nixosModules.default
    ];
  };
}

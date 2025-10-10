{ catppuccin, ... }:
{
  process-recipe = _: {
    modules = [
      catppuccin.nixosModules.catppuccin
    ];
  };
}

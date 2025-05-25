{ catppuccin, ... }:
{
  process-recipe = _: {
    modules = [
      catppuccin.homeModules.catppuccin
    ];
  };
}
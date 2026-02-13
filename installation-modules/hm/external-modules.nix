{ catppuccin, awesome-iwm, ... }:
{
  process-recipe = _: {
    modules = [
      catppuccin.homeModules.catppuccin
      awesome-iwm.homeModules.awesome-iwm
    ];
  };
}

{ catppuccin, awesome-iwm, ... }:
{
  process-recipe = _: {
    modules = [
      catppuccin.nixosModules.catppuccin
      awesome-iwm.nixosModules.awesome-iwm
    ];
  };
}

{ catppuccin, awesome-iwm, nix-index-database, steam-config, ... }:
{
  process-recipe = _: {
    modules = [
      catppuccin.nixosModules.catppuccin
      awesome-iwm.nixosModules.awesome-iwm
      nix-index-database.nixosModules.default
      steam-config.nixosModules.default

      ./nixos-modules
    ];
  };
}

{
  catppuccin,
  awesome-iwm,
  nix-index-database,
  nixpkgs,
  ...
}:
{
  process-recipe = _: {
    modules = [
      catppuccin.homeModules.catppuccin
      awesome-iwm.homeModules.awesome-iwm
      nix-index-database.homeModules.default
    ]
    ++ (nixpkgs.lib.optional (builtins.pathExists "/etc/nix-adhoc-conf/home.nix") /etc/nix-adhoc-conf/home.nix)
    ++ (nixpkgs.lib.optional (builtins.pathExists "/etc/nix-adhoc-conf/home-manager.nix") /etc/nix-adhoc-conf/home-manager.nix);
  };
}

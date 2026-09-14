{ nix-polyfils, ... }:
{
  process-recipe = _: {
    modules = [ nix-polyfils.homeManagerModules.default ];
  };
}

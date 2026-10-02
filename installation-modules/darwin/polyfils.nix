{ nix-polyfils, ... }:
{
  process-recipe = _: {
    modules = [ nix-polyfils.darwinModules.default ];
  };
}

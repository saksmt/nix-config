{ nix-polyfils, ... }:
{
  process-recipe = _: {
    modules = [ nix-polyfils.nixosModules.default ];
  };
}

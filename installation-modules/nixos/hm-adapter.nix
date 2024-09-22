{ nix-hm-adapter, ... }:
{
  process-recipe = _: {
    modules = [ nix-hm-adapter.nixosModules.default ];
  };
}

{ nix-hm-adapter, ... }:
{
  process-recipe = _: {
    modules = [ nix-hm-adapter.homeManagerModules.default ];
  };
}

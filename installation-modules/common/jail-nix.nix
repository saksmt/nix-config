{ jail-nix, ... }: {
  process-recipe = _: {
    modules = [({ pkgs, ... }: {
      _module.args.jail = jail-nix.lib.extend {
        inherit pkgs;
      };
    })];
  };
}
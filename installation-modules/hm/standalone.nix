_: {
  process-recipe = _: {
    modules = [
      (
        { pkgs, ... }:
        {
          home.packages = [ pkgs.home-rebuild ];
        }
      )
    ];
  };
}

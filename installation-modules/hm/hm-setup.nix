_: {
  process-recipe = _: {
    modules = [
      (
        { lib, ... }:
        {
          programs.home-manager.enable = true;
        }
      )
    ];
  };
}

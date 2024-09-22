_: {
  process-recipe = _: {
    modules = [
      (
        { lib, ... }:
        {
          home.stateVersion = lib.mkDefault "24.05";
          programs.home-manager.enable = true;
        }
      )
    ];
  };
}

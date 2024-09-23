_: {
  process-recipe = _: {
    modules = [
      (
        { pkgs, ... }:
        {
          home.packages = [ pkgs.home-rebuild ];
          nix.enable = true;
          nix.package = pkgs.nix;
        }
      )

      # backport from home-manager master
      ({config, lib, ...}: {
        options.nix.nixPath = with lib; lib.mkOption {
          type = types.listOf types.str;
          default = [];
        };

        config.home.sessionVariables.NIX_PATH = "${builtins.concatStringsSep ":" config.nix.nixPath}\${NIX_PATH:+:$NIX_PATH}";
      })
    ];
  };
}

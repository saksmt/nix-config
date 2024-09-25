_: {
  process-recipe = _: {
    modules = [
      (
        {
          pkgs,
          lib,
          config,
          ...
        }:
        {
          home.packages = [ pkgs.home-rebuild ];
          nix.enable = true;
          nix.package = pkgs.nix;

          nix.registry = {
            home.to = builtins.parseFlakeRef (
              lib.strings.fileContents "${config.home.homeDirectory}/.config/hm/flake-ref"
            );
            tpl.to = builtins.parseFlakeRef (
              lib.strings.fileContents "${config.home.homeDirectory}/.config/hm/flake-ref"
            );
          };

          # for some reason hm is missing those...
          home.sessionVariables = {
            TERMINFO_DIRS =
              "\${TERMINFO_DIRS:+$TERMINFO_DIRS:}"
              + (builtins.concatStringsSep ":" [
                "\${HOME}/.nix-profile/share/terminfo"
                "\${XDG_STATE_HOME}/nix/profile/share/terminfo"
                "\${HOME}/.local/state/nix/profile/share/terminfo"
                "\${HOME}/.local/state/nix/profiles/home-manager/home-path/share/terminfo"
                "\${HOME}/.local/state/nix/profiles/profile/share/terminfo"
              ]);

            LIBEXEC_PATH =
              "\${LIBEXEC_PATH:+$LIBEXEC_PATH:}"
              + (builtins.concatStringsSep ":" [
                "\${HOME}/.nix-profile/libexec"
                "\${XDG_STATE_HOME}/nix/profile/libexec"
                "\${HOME}/.local/state/nix/profile/libexec"
                "\${HOME}/.local/state/nix/profiles/home-manager/home-path/libexec"
                "\${HOME}/.local/state/nix/profiles/profile/libexec"
              ]);
          };
        }
      )

      # backport from home-manager master
      (
        { config, lib, ... }:
        {
          options.nix.nixPath =
            with lib;
            lib.mkOption {
              type = types.listOf types.str;
              default = [ ];
            };

          config.home.sessionVariables.NIX_PATH = "${builtins.concatStringsSep ":" config.nix.nixPath}\${NIX_PATH:+:$NIX_PATH}";
        }
      )
    ];
  };
}

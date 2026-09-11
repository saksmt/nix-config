{
  lib,
  pkgs,
  ...
}:

let
  syncoidWrapped = pkgs.writeShellApplication {
    name = "syncoid";
    runtimeInputs = [
      pkgs.sanoid
      pkgs.zfs
      pkgs.coreutils
    ];
    text = ''
      #shellcheck disable=SC1090
      # ^ - disabling inability to resovle dynamic sourcing

      # If the module generated a hooks file, source it into the current shell
      if [ -n "''${HOOKS_PATH:-}" ]; then
        source "$HOOKS_PATH"
        pre_hook "$SOURCE" "$TARGET"
      fi

      # Temporarily disable exit-on-error to capture Syncoid's exit code
      set +e
      ${pkgs.sanoid}/bin/syncoid "$@"
      export EXIT_STATUS=$?
      set -e

      if [ -n "''${HOOKS_PATH:-}" ]; then
        post_hook "$SOURCE" "$TARGET" "$EXIT_STATUS"
      fi

      exit "$EXIT_STATUS"
    '';
  };
in
{
  config.services.syncoid.package = syncoidWrapped;

  options.services.syncoid.commands = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, name, ... }: {
          options = {
            hookPackages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [];
              description = "Packages that will be available in the pre and post hook environment";
            };

            preHook = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = ''
              Bash snippet run before syncoid. Shares environment with post hook.

              Environment variables:
               - SYNCOID_COMMAND_NAME
               - SOURCE
               - TARGET

              Arguments:
               - source data set
               - target data set
              '';
            };
            postHook = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = ''
              Bash snippet run after syncoid. Shares environment with pre hook.

              Environment variables:
               - SYNCOID_COMMAND_NAME
               - SOURCE
               - TARGET
               - EXIT_STATUS

              Arguments:
               - source data set
               - target data set
               - exit status of syncoid command
              '';
            };
          };

          config = lib.mkIf (config.preHook != "" || config.postHook != "") {
            service.environment.HOOKS_PATH = pkgs.writeText "syncoid-hooks-${name}.sh" ''
              SYNCOID_COMMAND_NAME="${name}"
              SOURCE="${config.source}"
              TARGET="${config.target}"

              pre_hook() {
                _originalPath="''${PATH}"
                PATH="''${_originalPath}:${lib.makeBinPath config.hookPackages}"
                ${config.preHook}
                PATH="''${_originalPath}"
              }
              post_hook() {
                _originalPath="''${PATH}"
                PATH="''${_originalPath}:${lib.makeBinPath config.hookPackages}"
                ${config.postHook}
                PATH="''${_originalPath}"
              }
            '';
          };
        }
      )
    );
  };
}

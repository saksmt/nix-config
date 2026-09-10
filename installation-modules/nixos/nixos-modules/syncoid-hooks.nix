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
      export SOURCE="''${@: -2:1}"
      export TARGET="''${@: -1}"

      # If the module generated a hooks file, source it into the current shell
      if [ -n "''${HOOKS_PATH:-}" ]; then
        source "$HOOKS_PATH"
        pre_hook "$SOURCE" "$TARGET"
      fi

      # Temporarily disable exit-on-error to capture Syncoid's exit code
      set +e
      ${pkgs.sanoid}/bin/syncoid "$@"
      EXIT_STATUS=$?
      set -e

      if [ -n "''${HOOKS_PATH:-}" ]; then
        post_hook "$SOURCE" "$TARGET" "$EXIT_STATUS"
      fi

      exit "$EXIT_STATUS"
    '';
  };
in
{
  services.syncoid.package = syncoidWrapped;

  options.services.syncoid.commands = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, name, ... }: {
          options = {
            preHook = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Bash snippet run before syncoid. Shares environment with post hook. Available environment variables: SYNCOID_COMMAND_NAME, SOURCE, TARGET";
            };
            postHook = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Bash snippet run after syncoid. Shares environment with pre hook. Available environment variables: SYNCOID_COMMAND_NAME, SOURCE, TARGET";
            };
          };

          config = lib.mkIf (config.preHook != "" || config.postHook != "") {
            service.environment.HOOKS_PATH = pkgs.writeText "syncoid-hooks-${name}.sh" ''
              SYNCOID_COMMAND_NAME="${name}"

              pre_hook() {
                ${config.preHook}
              }
              post_hook() {
                ${config.postHook}
              }
            '';
          };
        }
      )
    );
  };
}

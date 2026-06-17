{
  features,
  config,
  jail,
  pkgs,
  host-config,
  lib,
  ...
}:
with features;
let
  forFeature = feature: lib.optionalAttrs feature.isEnabled;
  cfg = config.opencode.plugins.interpreters;
  jsonFormat = pkgs.formats.json { };
  # temporary solution until proper caging is done
  restricted-bash = (
    jail "restricted-bash" pkgs.bash (
      with jail.combinators;
      [
        (nix host-config.nix)
        transparent
        network
        terminfo
        base-linux-utils
        modern-linux-utils
        xdg
        git-config
        (add-pkg-deps pkgs.git)
      ]
    )
  );
  defaultConfiguration = {
    bash = {
      interpreter = lib.getExe restricted-bash;
      sandboxed = true;
      prompt.afterSandbox = ''
        The following packages are available:
         - gnu coreutils
         - modern linux utilities: fd, rg, jq, jo, yq
         - standard linux utilities: sed, awk, curl, wget, find, grep
         - nix (you can enter `nix develop` shells when flake.nix is available)
        Prefer using modern utilities when there exists an alternative:
         - rg instead of grep
         - fd instead of find
        If rg can not find something you're sure exists, remember about .gitignore and try using `--no-ignore` and/or `--hidden`

        IMPORTANT: You may only use grep/read tools to read truncated output of this tool! Output file WILL NOT be available inside sandbox!
      '';
    };
  };
in
{
  options.opencode.plugins.interpreters = {
    enable = lib.mkEnableOption "interpreters" // {
      default = true;
    };
    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = "opencode interpreters configuration";
    };
  };

  config = forFeature dev.common {
    opencode.confd."000-shared/plugins/interpreters" = lib.mkIf cfg.enable {
      plugin = [
        [
          "opencode-interpreters-plugin@0.1.0"
          (lib.attrsets.recursiveUpdate defaultConfiguration cfg.settings)
        ]
      ];
    };
  };
}

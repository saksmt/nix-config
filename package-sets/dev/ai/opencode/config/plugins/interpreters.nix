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
      (
        [
          (nix host-config.nix)
          transparent
          network
          terminfo
          base-linux-utils
          modern-linux-utils
          xdg
          git-config
          (add-pkg-deps [ pkgs.git ])
        ]
        ++ (lib.optionals features.dev.k8s.isEnabled [
          (try-readonly (noescape "~/.test-k8s/kubeconfig"))
          (jail-to-host-channel "_testK8sChan" ''
            if [[ "$(echo "''${1}" | jq -r '. | length')" == "2" ]]; then
              test-k8s "$(echo "''${1}" | jq -r '.[0]')" "$(echo "''${1}" | jq -r '.[1]')"
            else
              test-k8s "$(echo "''${1}" | jq -r '.[0]')"
            fi
          '')
          (add-pkg-deps [
            (pkgs.writeShellApplication {
              name = "test-k8s";
              text = ''
                json-args() {
                  {
                    echo "''${1}"
                    if [[ n"''${2:-""}" != n ]]; then
                      echo "''${2}"
                    fi
                  } | jq -R | jq -sc
                }
                case "''${1:-""}" in
                  create ) _testK8sChan "$(json-args create "''${2:-""}")" ;;
                  delete ) _testK8sChan "$(json-args delete "''${2:-""}")" ;;
                  * )
                    echo "usage: test-k8s <create|delete> [name]"
                    echo "(readonly) kube config at: ~/.test-k8s/kubeconfig"
                  ;;
                esac
              '';
            })
          ])
        ])
        ++ (lib.optionals features.dev.rust.isEnabled [
          (try-readwrite (noescape "~/.cache/cargo-registry"))
          (wrap-entry (entry: ''
            mkdir -p ~/.cargo &>/dev/null || true
            ln -s ~/.cache/cargo-registry ~/.cargo/registry &>/dev/null || true

            ${entry}
          ''))
        ])
      )
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
          "/home/smt/code/opensource/opencode-plugins/opencode-interpreters-plugin"
          { interpreters = (lib.attrsets.recursiveUpdate defaultConfiguration cfg.settings); }
        ]
      ];
    };

    install.packages = lib.mkIf cfg.enable [ restricted-bash ];
    programs.sandbox-store.enable = cfg.enable;
  };
}

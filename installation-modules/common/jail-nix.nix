{ jail-nix, ... }:
{
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
          _module.args.jail = jail-nix.lib.extend {
            inherit pkgs;

            additionalCombinators =
              builtinCombinators: with builtinCombinators; rec {
                host-nix-store = compose [
                  (try-readonly "/nix/store")
                ];

                nix-overlay-store = compose [
                  (add-runtime ''
                    OVERLAY_ID="$(readlink -f "$(pwd)" | xxhsum | cut -d' ' -f1)"
                    SANDBOX_ROOT="''${HOME}/.local/state/sandbox"
                    OVERLAY_ROOT="''${SANDBOX_ROOT}/''${OVERLAY_ID}"

                    mkdir -p "''${OVERLAY_ROOT}/"{upper,work,merged} &>/dev/null || true

                    [[ -f "''${SANDBOX_ROOT}"/index.json ]] || { echo '{}' > "''${SANDBOX_ROOT}"/index.json; }
                    jq '.[$id] |= $path' "''${SANDBOX_ROOT}"/index.json \
                      --arg id "$OVERLAY_ID" \
                      --arg path "$(readlink -f "$(pwd)")" \
                      | sponge "''${SANDBOX_ROOT}"/index.json

                    # todo: find userspace alternative
                    sudo mount -t overlay overlay \
                      -o lowerdir=/nix/store \
                      -o upperdir="''${OVERLAY_ROOT}/upper" \
                      -o workdir="''${OVERLAY_ROOT}/work" \
                      "''${OVERLAY_ROOT}/merged"
                  '')
                  (add-cleanup ''
                    sudo umount "''${OVERLAY_ROOT}/merged"
                  '')
                  # mounting only store database and store itself.
                  # NOT user profiles and more critically nix socket
                  (try-ro-bind "/nix/store" "/nix/host-store/nix/store")
                  (try-ro-bind "/nix/var/nix/db" "/nix/host-store/nix/var/nix/db")
                  (try-rw-bind (noescape "\"\${OVERLAY_ROOT}\"/upper") "/nix/upper-layer")
                  (try-rw-bind (noescape "\"\${OVERLAY_ROOT}\"/work") "/nix/overlay-work")
                  (try-rw-bind (noescape "\"\${OVERLAY_ROOT}\"/merged") "/nix/store")
                ];

                nix =
                  nixCfg:
                  compose [
                    nix-overlay-store
                    (add-pkg-deps [ pkgs.nix ])
                    fake-passwd
                    (bind-pkg "/etc/nix/nix.conf" (
                      (pkgs.formats.nixConf {
                        inherit (nixCfg) extraOptions package;
                        version = nixCfg.package.out.version;
                      }).generate
                        "overlayed-jail-nix.conf"
                        (
                          nixCfg.settings
                          // {
                            experimental-features = (nixCfg.settings.experimental-features or { }) ++ [
                              "local-overlay-store"
                              "read-only-local-store"
                            ];
                            store = "local-overlay://?lower-store=%2Fnix%2Fhost-store%3Fread-only%3Dtrue&upper-layer=%2Fnix%2Fupper-layer&check-mount=false";
                          }
                        )
                    ))
                    (write-text "/etc/nix/registry.json" (
                      builtins.toJSON {
                        version = 2;
                        flakes = lib.mapAttrsToList (n: v: { inherit (v) from to exact; }) nixCfg.registry;
                      }
                    ))
                    (set-env "NIX_PATH" (builtins.concatStringsSep ":" nixCfg.nixPath))
                  ];

                host-hostname = compose [
                  (set-hostname (
                    lib.trim ((config.networking or { }).hostName or (builtins.readFile "/etc/hostname"))
                  ))
                ];

                transparent = compose [
                  mount-cwd
                  host-hostname
                  time-zone
                ];

                terminfo = compose [
                  (readonly-paths-from-var "TERMINFO_DIRS" ":")
                  (try-readonly (noescape "\"$TERMINFO\""))
                  # TIOCSTI is disabled by default, no need to break anything to avoid it
                  no-new-session
                  (add-pkg-deps [ pkgs.ncurses ])
                ];

                base-linux-utils =
                  with pkgs;
                  compose [
                    (add-pkg-deps [
                      gnugrep
                      gnused
                      bash
                      coreutils
                      gawk
                      curl
                      gnutar
                      zip
                      unzip
                      wget
                      findutils
                      which
                    ])
                    (defer (
                      wrap-entry (entry: ''
                        mkdir -p /usr/bin
                        ln -s "$(readlink -f "$(which env)")" /usr/bin/env
                        ${entry}
                      '')
                    ))
                  ];
                modern-linux-utils = compose [
                  (add-pkg-deps (
                    with pkgs;
                    [
                      ripgrep
                      jq
                      fd
                      yq
                      jo
                    ]
                  ))
                ];

                git-config = compose [
                  (try-readonly (noescape "~/.gitconfig"))
                  (try-readonly (noescape "~/.config/git"))
                  (try-readonly (noescape "~/.git"))
                ];

                run-dir = compose [
                  (try-fwd-env "XDG_RUNTIME_DIR")
                  (unsafe-add-raw-args "--dir /run/user/\"$(id -u)\"")
                  (unsafe-add-raw-args "--dir /var")
                  (unsafe-add-raw-args "--symlink ../run /var/run")
                ];

                xdg-dirs = compose [
                  (try-fwd-env "XDG_CACHE_HOME")
                  (try-fwd-env "XDG_CONFIG_HOME")
                  (try-fwd-env "XDG_DATA_HOME")
                  (try-fwd-env "XDG_STATE_HOME")
                ];
                xdg = compose [
                  fake-passwd
                  run-dir
                  xdg-dirs
                ];
              };
          };
        }
      )
    ];
  };
}

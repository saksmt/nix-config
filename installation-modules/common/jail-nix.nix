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
        let
          sandbox-store = pkgs.writeShellApplication {
            name = "sandbox-store";
            runtimeInputs = [
              pkgs.jq
              pkgs.xxhash
              pkgs.moreutils
            ];

            text = ''
              # shellcheck disable=SC1091
              source /usr/local/etc/colors.sh
              # shellcheck disable=SC1091
              source /usr/local/lib/prompt
              # Declare external variables for shellcheck without affecting runtime
              if false; then
                export listItem=
                export clr=
                export success=
                export info=
                export warn=
                export bright=
                export white=
                export dim=
                export error=
              fi

              SANDBOX_ROOT="''${HOME}/.local/state/sandbox"
              [[ -f "''${SANDBOX_ROOT}"/index.json ]] || { echo '{}' > "''${SANDBOX_ROOT}"/index.json; }

              OVERLAY_ID="$(readlink -f "$(pwd)" | xxhsum | cut -d' ' -f1)"
              OVERLAY_ROOT="''${SANDBOX_ROOT}/''${OVERLAY_ID}"

              before-sandbox() {
                RUN_ID="$(uuidgen)"

                mkdir -p "''${OVERLAY_ROOT}/base/"{upper,work,merged} &>/dev/null || true

                jq '.[$id] |= { path: $path, timestamp: $timestamp }' "''${SANDBOX_ROOT}"/index.json \
                  --arg id "$OVERLAY_ID" \
                  --arg path "$(readlink -f "$(pwd)")" \
                  --arg timestamp "$(date +%s)" \
                  | sponge "''${SANDBOX_ROOT}"/index.json

                # protection against parallel runs (they hang silently on attempting to set same overlayfs on same paths),
                # idea is to work on a copy and then move it back
                # making last to finish win
                OVERLAY_RUN_ROOT="''${OVERLAY_ROOT}/instance/''${RUN_ID}"
                mkdir -p "''${OVERLAY_ROOT}/instance"
                # creating instance from base, sudo pollution is due to overlayfs mounted as root
                sudo cp -a --reflink=always -R "''${OVERLAY_ROOT}/base" "''${OVERLAY_RUN_ROOT}"

                # todo: find userspace alternative
                sudo mount -t overlay overlay \
                  -o lowerdir=/nix/store \
                  -o upperdir="''${OVERLAY_RUN_ROOT}/upper" \
                  -o workdir="''${OVERLAY_RUN_ROOT}/work" \
                  "''${OVERLAY_RUN_ROOT}/merged"

                # return:
                echo "''${OVERLAY_RUN_ROOT}"
              }

              after-sandbox() {
                OVERLAY_RUN_ROOT="''${1}"

                sudo umount "''${OVERLAY_RUN_ROOT}/merged"
                # atomically exchanging base and instance directories
                sudo mv -fT --exchange "''${OVERLAY_RUN_ROOT}" "''${OVERLAY_ROOT}/base"
                # dropping old base that became instance
                sudo rm -rf "''${OVERLAY_RUN_ROOT}"
              }

              list-sandboxes() {
                cd "''${SANDBOX_ROOT}" || {
                  echo "No sandboxes";
                  exit 0
                }

                bySize=n
                case "''${1:-""}" in
                  size | by-size | sort-size | --sort=size )
                    bySize=y
                    ;;
                  * ) ;;
                esac

                if [[ "''${1:-""}" == "--sort" ]] && [[ "''${2:-""}" == "size" ]]; then
                  bySize=y
                fi

                if [ -e index.json ] && [[ "$(cat index.json | jq '. | length')" != "0" ]]; then
                  now="$(date +%s)"

                  echo "''${info}Sandbox stores:"
                  if [[ "''${bySize}" == "y" ]]; then
                      sudo du -sb ./* | grep -v index.json | sort -nr | {
                        while read -r size sandboxPath; do
                          quotedId='"'"${"\${sandboxPath:2}"}"'"'
                          path="$(realpath "--relative-to=''${HOME}" "$(cat index.json | jq -r ".[''${quotedId}].path")")"
                          lastAccessTimestamp="$(cat index.json | jq -r ".[''${quotedId}].timestamp")"
                          lastAccess="$(PRECISION=2 millis-to-duration "$((now - lastAccessTimestamp))000")"
                          echo "''${listItem} $(numfmt --to=iec "''${size}")b for ''${bright}''${white}''${path}''${clr} [''${dim}last accessed ''${lastAccess} ago''${clr}]"
                        done
                      }
                  else
                    cat index.json \
                    | jq -r 'to_entries | sort_by(-(.value.timestamp | tonumber)) | .[] | [.key, .value.timestamp, .value.path] | @tsv' \
                    | {
                      IFS=$'\t'
                      while read -r id lastAccessTimestamp absolutePath; do
                        size="$(sudo du -sb "./''${id}" | cut -f1)"
                        path="$(realpath "--relative-to=''${HOME}" "''${absolutePath}")"
                        lastAccess="$(PRECISION=2 millis-to-duration "$((now - lastAccessTimestamp))000")"
                        echo "''${listItem} $(numfmt --to=iec "''${size}")b for ''${bright}''${white}''${path}''${clr} [''${dim}last accessed ''${lastAccess} ago''${clr}]"
                      done
                    }
                  fi
                else
                  echo "''${info}No sandbox stores"
                fi
              }

              rm-sandboxes() {
                IFS=$'\t'
                now="$(date +%s)"
                totalReclaimedSpace=0

                while (( $# > 0 )); do
                  input="''${1}"
                  shift

                  maybePath="$(readlink -f "''${input}")"
                  maybeId="$(realpath --relative-to="''${SANDBOX_ROOT}" "''${maybePath}")"
                  read -r id lastAccessTimestamp path <<< "$(
                    cat "''${SANDBOX_ROOT}/index.json" | \
                      jq '(. | to_entries | map(. as $e | .value.id |= $e.key) | from_entries)' | \
                      jq -r \
                        --arg input "''${input}" \
                        --arg id "''${maybeId}" \
                        --arg path "''${maybePath}" \
                        '(.[$input] // .[$id] // (. | to_entries | map({ key: .value.path, value }) | from_entries)[$path]) | [ .id, .timestamp, .path ] | @tsv' \
                  )"

                  if [[ n"''${id:-""}" == n ]]; then
                    echo "''${error}Unknown sandbox: ''${bright}''${white}''${input}''${clr}"
                    continue
                  fi
                  relativePath="$(realpath --relative-to="''${HOME}" "''${path}")"
                  lastAccess="$(PRECISION=2 millis-to-duration "$((now - lastAccessTimestamp))000")"
                  echo "''${warn}Removing sandbox for ''${bright}''${white}~/''${relativePath}''${clr} last accessed ''${lastAccess} ago"
                  size="$(sudo du -sb "''${SANDBOX_ROOT}/''${id}" | cut -f1)"
                  echo "''${info}Size on disk: $(numfmt --to=iec "''${size}")b"
                  if prompt "Proceed?" inverse; then
                    totalReclaimedSpace=$(( totalReclaimedSpace + $(sudo du -sb "''${SANDBOX_ROOT}/''${id}" | cut -f1) ))
                    echo sudo rm -rf "''${SANDBOX_ROOT}/''${id}"
                  else
                    echo "''${info}Skipping"
                  fi
                done
                echo "''${info}Total reclaimed space: ''${bright}''${white}$(numfmt --to=iec "''${totalReclaimedSpace}")b''${clr}"
              }

              gc-sandboxes() {
                period=""
                if (( $# > 0 )); then
                  period="$(duration-to-millis "''${@}")"
                else
                  period="$(duration-to-millis 60d)"
                fi

                now="$(date +%s)000"
                cutoff=$(( (now - period)/1000 ))
                total="$(\
                  cat "''${SANDBOX_ROOT}/index.json" | \
                    jq --arg cutoff "''${cutoff}" 'to_entries | map(.value) | map(select(.timestamp < $cutoff)) | length' \
                )"

                humanDate="''${bright}''${white}$(date --date="@''${cutoff}")''${clr}"
                if [[ "''${total}" == "0" ]]; then
                  echo "''${info}No sandboxes older than ''${humanDate}"
                else
                  echo "''${info}Dropping ''${bright}''${white}''${total}''${clr} sandboxes older than ''${humanDate}"
                  mapfile -t candidates < <(\
                    cat "''${SANDBOX_ROOT}/index.json" | \
                      jq -r --arg cutoff "''${cutoff}" 'to_entries[] | select(.value.timestamp < $cutoff) | .key' \
                  )
                  rm-sandboxes "''${candidates[@]}"
                fi
              }

              case "''${1:-""}" in
                before-sandbox )
                  shift
                  before-sandbox "''${@}"
                  ;;
                after-sandbox )
                  shift
                  after-sandbox "''${@}"
                  ;;
                list )
                  shift
                  list-sandboxes "''${@}"
                  ;;
                rm )
                  shift
                  rm-sandboxes "''${@}"
                  ;;
                gc )
                  shift
                  gc-sandboxes "''${@}"
                  ;;
                * )
                  echo "usage: sandbox-store <before-sandbox|after-sandbox|list|rm|gc>"
              esac
            '';
          };
        in
        {
          imports = [
            {
              options.programs.sandbox-store.enable = lib.mkEnableOption "sandbox store management script";
              config.install.packages =
                lib.mkIf (config.programs.sandbox-store.enable && !pkgs.stdenv.hostPlatform.isDarwin)
                  [
                    sandbox-store
                  ];
            }
          ];
          _module.args.jail = jail-nix.lib.extend {
            inherit pkgs;

            additionalCombinators =
              builtinCombinators: with builtinCombinators; rec {
                host-nix-store = compose [
                  (try-readonly "/nix/store")
                ];

                nix-overlay-store = compose [
                  (add-runtime ''
                    OVERLAY_RUN_ROOT="$(${sandbox-store}/bin/sandbox-store before-sandbox)"
                  '')
                  (add-cleanup ''${sandbox-store}/bin/sandbox-store after-sandbox "''${OVERLAY_RUN_ROOT}"'')
                  # mounting only store database and store itself.
                  # NOT user profiles and more critically nix socket
                  (try-ro-bind "/nix/store" "/nix/host-store/nix/store")
                  (try-ro-bind "/nix/var/nix/db" "/nix/host-store/nix/var/nix/db")
                  (try-rw-bind (noescape "\"\${OVERLAY_RUN_ROOT}\"/upper") "/nix/upper-layer")
                  # (try-rw-bind (noescape "\"\${OVERLAY_RUN_ROOT}\"/work") "/nix/overlay-work")
                  (try-rw-bind (noescape "\"\${OVERLAY_RUN_ROOT}\"/merged") "/nix/store")
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
                      diffutils
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

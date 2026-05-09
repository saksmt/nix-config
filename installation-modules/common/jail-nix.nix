{ jail-nix, ... }:
{
  process-recipe = _: {
    modules = [
      (
        { pkgs, lib, ... }:
        {
          _module.args.jail = jail-nix.lib.extend {
            inherit pkgs;

            additionalCombinators =
              builtinCombinators: with builtinCombinators; rec {
                host-nix-store = compose [
                  (try-readonly "/nix/store")
                ];

                host-hostname = compose [
                  (set-hostname (lib.trim (builtins.readFile "/etc/hostname")))
                ];

                transparent = compose [
                  mount-cwd
                  host-hostname
                  time-zone
                ];

                terminfo = compose [
                  (readonly-paths-from-var "TERMINFO_DIRS" ":")
                  (try-readonly (noescape "\"$TERMINFO\""))
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

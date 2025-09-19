{
  writeShellApplication,
  nh,
  nix-output-monitor,
  git,
}:
writeShellApplication {
  name = "home";

  derivationArgs = {
    pname = "home-rebuild-script";
    meta = {
      name = "home-rebuild-script";
    };
  };

  runtimeInputs = [
    nh
    nix-output-monitor
    git
  ];

  text = ''
    ASK_FLAG="''${NO_ASK:---ask}"
    read -r -a nixOpts <<< "''${NH_NIX_OPTS:-}"

    if ! [[ -f "''${HOME}/.config/hm/flake-ref" ]]; then
      echo "Can not find flake reference to build upon. Did you properly install config?" >&2
      exit 1
    fi
    thisFlake="$(< "''${HOME}/.config/hm/flake-ref")"

    thisConfig="$(whoami)"
    if [[ -f "''${HOME}/.config/hm/user-config-ref" ]]; then
      thisConfig="$(< "''${HOME}/.config/hm/user-config-ref")"
    fi

    rebuildArgs=( \
      "''${ASK_FLAG}" \
      "''${thisFlake}" \
      '-c' \
      "''${thisConfig}" \
    )

    case "''${1:-}" in
      build ) shift; nh home build "''${rebuildArgs[@]}" "''${@}" -- "''${nixOpts[@]}" --impure ; ;;
      switch ) shift; nh home switch "''${rebuildArgs[@]}" "''${@}" -- "''${nixOpts[@]}" --impure ; ;;
      update )
        preThisFlakePath="''${thisFlake#'git+file:'}"
        thisFlakePath="''${preThisFlakePath#'path:'}"
        cd "''${thisFlakePath}" || { echo "''${thisFlakePath}"' does not exist!'; exit 1; }
        git pull
        nix flake update
        ;;
      repl )
        shift;
        flake="''${thisFlake}"
        if [[ "''${1:-}" == "--built" ]]; then
          flake=built-hm
          shift
        fi
        nix repl --extra-experimental-features 'flakes repl-flake' "''${flake}#repl" "''${@}"
        ;;
      *)
        echo "Unknown argument to home: ''${1}" >&2;
        exit 1;
        ;;
    esac
  '';
}

{
  writeShellApplication,
  nh,
  nix-output-monitor,
  git,
  lib,
}:
let
  onCI = builtins.getEnv "CI" != "";
  thisFlake =
    if (builtins.pathExists "/etc/nixos/flake-ref") then
      lib.strings.fileContents "/etc/nixos/flake-ref"
    else if (onCI) then
      "NOT_AVAILABLE"
    else
      builtins.throw "No reference to this flake specified in /etc/nixos/flake-ref";
  thisHost =
    if (builtins.pathExists "/etc/nixos/host-ref") then
      lib.strings.fileContents "/etc/nixos/host-ref"
    else
      "$(hostname)";

  thisFlakePath = lib.strings.removePrefix "path:" (lib.strings.removePrefix "git+file:" thisFlake);
  var = name: "\${${name}}";
  quotedVar = name: ''"${var name}"'';
  buildOpts = builtins.concatStringsSep " " [
    (quotedVar "ASK_FLAG")
    (lib.strings.escapeShellArg thisFlake)
    "-H"
    (lib.strings.escapeShellArg thisHost)
    (quotedVar "@")
    "--"
    (quotedVar "nixOpts[@]")
    "--impure"
  ];
  script = ''
    ASK_FLAG="''${NO_ASK:---ask}"
    read -r -a nixOpts <<< "''${NH_NIX_OPTS:-}"
    case "''${1:-}" in
      build ) shift; nh os build ${buildOpts}; ;;
      switch ) shift; nh os switch ${buildOpts}; ;;
      boot ) shift; nh os boot ${buildOpts}; ;;
      pull )
        cd ${lib.strings.escapeShellArg thisFlakePath} || { echo ${lib.strings.escapeShellArg thisFlakePath}' does not exist!'; exit 1; }
        git pull
        ;;
      update )
        cd ${lib.strings.escapeShellArg thisFlakePath} || { echo ${lib.strings.escapeShellArg thisFlakePath}' does not exist!'; exit 1; }
        nix flake update
        ;;
      pull-and-update )
        cd ${lib.strings.escapeShellArg thisFlakePath} || { echo ${lib.strings.escapeShellArg thisFlakePath}' does not exist!'; exit 1; }
        git pull
        nix flake update
        ;;
      repl )
        shift;
        flake=${lib.strings.escapeShellArg thisFlake}
        if [[ "''${1:-}" == "--built" ]]; then
          flake=built-os
          shift
        fi
        nix repl --extra-experimental-features 'flakes repl-flake' $flake"#repl" "''${@}"
        ;;
      *)
        echo "Unknown argument to os: ''${1}" >&2;
        exit 1;
        ;;
    esac
  '';
in
writeShellApplication {
  name = "os";

  derivationArgs = {
    pname = "os-rebuild-script";
    meta = {
      name = "os-rebuild-script";
    };
  };

  runtimeInputs = [
    nh
    nix-output-monitor
    git
  ];

  text =
    if onCI then
      ''
        echo "THIS IS WAS A CI BUILD. os COMMAND IS NOT AVAILABLE" >&2;
        exit 1;
      ''
    else
      script;
}

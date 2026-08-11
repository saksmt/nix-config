{ pkgs, lib, ... }:
{
  module-for = [
    "hm"
    "nixos"
  ];

  install.packages = with pkgs; [
    # because there can be no quality of life without kitties.
    kittysay

    (writeShellScriptBin "zsh-interactive" ''
      exec zsh -ic "''${@}"
    '')

    bat
    bat-extras.batdiff
    bat-extras.batman
    bat-extras.batpipe
    bat-extras.batwatch
    fzf
    ripgrep
    wget
    fd
    jq
    jo
    yq
    difftastic

    lsof
    # fuser
    psmisc

    openssh
    zip
    unzip
    zstd
    libsecret
    moreutils
    gnupg
    xxhash

    socat
    inetutils
    iproute2

    sshfs

    # alias to configured default editor
    (writeShellApplication {
      name = "ee";
      text = "exec \${EDITOR} \"\${@}\"";
    })
  ];

  shells.zsh.enable = true;
  shells.zsh = {
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "sudo"
        "fzf"
        "aliases"
        "kubectl"
        "command-not-found"
      ];
      theme = "gentoo";
    };

    rc-extra = {
      bottom = ''
        ${lib.getExe pkgs.any-nix-shell} zsh --info-right | source /dev/stdin

        function whereami() {
          dim="$(echo -e '\033[2m')"
          clr="$(echo -e '\033[0m')"
          warnSign_zsh="%F{yellow}⚠%f"
          print -P " %F{cyan}*%f %{$dim%}host%{$clr%}:\t$(hostname)"
          if [[ n"''${SSH_CLIENT}" != n ]]; then
            print -P "   (%F{yellow}ssh%f) from IP:\t$(echo "''${SSH_CLIENT}" | cut -d' ' -f1)"
          fi
          if command -v kubectl &>/dev/null; then
            helm="⎈"
            context=$(kubectl config current-context)
            k8snamespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
            westHint=
            eastHint=
            if [[ "''${context}" =~ .*us-primary.* ]]; then
              westHint="%{$dim%}(west)%{$clr%}"
            fi
            if [[ "''${context}" =~ .*us-backup.* ]]; then
              eastHint="%{$dim%}(east)%{$clr%}"
            fi
            if [[ "''${context}" == PROD_* ]]; then
                helm="%F{red}''${helm}%f"
                context="''${warnSign_zsh} %F{red}%BPROD%f%b ''${warnSign_zsh} %F{red}''${context//PROD_}%f"
            elif [[ "''${context}" == beta ]]; then
                helm="%F{yellow}''${helm}%f"
                context="''${warnSign_zsh} %F{yellow}beta%f ''${warnSign_zsh}"
            else
                helm="%F{cyan}''${helm}%f"
            fi
            print -P " ''${helm} %{$dim%}kubernetes%{$clr%}:\t''${context}\t''${eastHint}''${westHint}"
          fi
        }

        yamldiff() {
          difft --graph-limit 20000000 --override '*:json' <(yq -S '.' "''${1}") <(yq -S '.' "''${2}")
        }

        jsondiff() {
          difft --graph-limit 20000000 --override '*:json' <(jq -S '.' "''${1}") <(jq -S '.' "''${2}")
        }

        whichlink() {
          readlink -f $(which "''${1}")
        }

        source-e() {
           set -a;
           while (( $# > 0 )); do
             file="''${1}"
             shift
             set -a;
             source "''${file}";
             set +a;
           done
        }
        load-env() {
          source-e "''${@}"
        }

        PATH="''${PATH}:/usr/local/bin:''${HOME}/.local/bin"
      '';
    };
  };
  shells.bash.enable = true;

  programs.zsh.shellAliases = {
    kdiff = "kitten diff";

    watch = "watch -c -x zsh-interactive";
  };

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  catppuccin.bat.enable = true;
  catppuccin.fzf.enable = true;
}

{ pkgs, lib, ... }:
{
  module-for = [
    "hm"
    "nixos"
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

        if command -v k8sps1 &>/dev/null; then
          export K8SPS1_SESSION_ID="''${RANDOM}"
          PROMPT+='$(k8sps1 get)'
        fi
        alias kps1=k8sps1

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

        ghelp() {

          echo "git aliases help ('-' - from ohmyzsh, '*' - custom):"
          echo " - gcn!         - amend, no edit message"
          echo " - gcan!        - amend, no edit message, add all"
          echo " * gcamend      - amend, no-endit-message, add all"
          echo " - grba         - abort rebase"
          echo " - grbc         - continue rebase"
          echo " - ggp [branch] - push branch (or current) to origin"
          echo " - ggpush       - push current branch to origin"
          echo " - gp           - git push"
          echo " - gpf!         - git push --force"
          echo " - ggf [branch] - force push or current"
          echo " * ggpf         - force push current"
          echo " * ggp!         - force push current"
          echo " - ggpull       - pull origin current branch"
          echo " - ggu [branch] - pull --rebase origin/branch or current"
          echo " * ggum         - pull --rebase origin/master"
          echo " * glm          - pull --rebase origin/master"
          echo " * grhho        - hard reset current branch to origin"
          echo " - grbi         - interactive rebase"

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
      '';
    };
  };
  shells.bash.enable = true;

  programs.zsh.shellAliases = {
    k = "kubectl";
    kg = "kubectl get";
    kd = "kubectl describe";

    kgy = "kubectl get -o yaml";

    kgsy = "kubectl get -o yaml svc";
    kgpy = "kubectl get -o yaml pod";
    kgssy = "kubectl get -o yaml ss";
    kgdy = "kubectl get -o yaml deployment";
    kgjy = "kubectl get -o yaml job";
    kgcjy = "kubectl get -o yaml cj";

    kexec = "kubectl exec";

    kcn = "k8s-interactive-choose namespace";
    kcc = "k8s-interactive-choose context";
    kcuc = "k8s-interactive-choose context";

    gcamend = "git commit -a --amend --no-edit";
    ggpf = "git push origin $(git_current_branch) --force";
    "ggp!" = "git push origin $(git_current_branch) --force";
    ggum = "git pull origin master --rebase";
    glm = "git pull origin master --rebase";
    grhho = "git reset --hard origin/$(git_current_branch)";

    kdiff = "kitten diff";

    lg = "lazygit";

    watch = "watch -c -x zsh-interactive";

  };

  programs.command-not-found.enable = true;
  programs.git.enable = true;
  programs.git.delta.enable = true;
  catppuccin.delta.enable = true;

  programs.lazygit.enable = true;
  catppuccin.lazygit.enable = true;
  programs.lazygit.settings = {
    gui = {
      nerdFontsVersion = "3";
      showDivergenceFromBaseBranch = "onlyArrow";
      filterMode = "fuzzy";
      sidePanelWidth = 0.2;
    };
    git.paging.pager = "delta --side-by-side --line-numbers --paging=never";
  };

  catppuccin.btop.enable = true;
  catppuccin.bat.enable = true;
  catppuccin.fzf.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  install.packages = with pkgs; [
    (writeShellScriptBin "zsh-interactive" ''
    exec zsh -ic "''${@}"
    '')

    btop
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
    unixtools.netstat

    iotop
    iftop
    powertop

    openssh
    unzip
    libsecret
    moreutils
    gnupg
    xxHash

    inetutils
    iproute2

    sshfs

    # alias to configured default editor
    (writeShellApplication {
       name = "ee";
       text = "exec \${EDITOR} \"\${@}\"";
     })
  ];
}

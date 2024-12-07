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

    kcn = "k8s-interactive-choose namespace";
    kcc = "k8s-interactive-choose context";
    kcuc = "k8s-interactive-choose context";
  };

  programs.command-not-found.enable = true;
  programs.git.enable = true;

  install.packages = with pkgs; [
    btop
    bat
    fzf
    ripgrep
    wget
    fd
    jq
    jo

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

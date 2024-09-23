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
      '';
    };
  };
  shells.bash.enable = true;

  programs.command-not-found.enable = true;

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

    git
    openssh
    unzip
    libsecret
    moreutils
    gnupg
    xxHash

    sshfs

    # alias to configured default editor
    (writeShellApplication {
       name = "ee";
       text = "exec \${EDITOR} \"\${@}\"";
     })
  ];
}

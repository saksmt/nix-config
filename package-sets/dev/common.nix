{
  pkgs,
  features,
  lib,
  ...
}:
with features;
{
  module-for = [
    "hm"
    "nixos"
  ];

  install.packages =
    with pkgs;
    (lib.lists.optionals dev.common.isEnabled ([
      graphviz
      httpie
    ])) ++ [ bintools ];
  services.emacs.enable = lib.mkDefault dev.common.isEnabled;
  services.emacs.defaultEditor = lib.mkDefault dev.common.isEnabled;
  services.emacs.package =
    if GUI.isEnabled then
      pkgs.emacs
    else
      (pkgs.emacs.override {
        noGui = true;
      });

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  programs.git.enable = true;
  programs.git.delta.enable = true;
  programs.delta.enableGitIntegration = true;
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

  programs.zsh.shellAliases = {
    gcamend = "git commit -a --amend --no-edit";
    ggpf = "git push origin $(git_current_branch) --force";
    "ggp!" = "git push origin $(git_current_branch) --force";
    ggum = "git pull origin master --rebase";
    glm = "git pull origin master --rebase";
    grhho = "git reset --hard origin/$(git_current_branch)";

    lg = "lazygit";
  };
  shells.zsh.rc-extra.bottom = ''

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

  '';
}

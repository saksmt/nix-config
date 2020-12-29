uses: { config, pkgs, ... }:
with uses;

{ imports = [

    {
        programs.vim.defaultEditor = true;

        security.sudo.enable = true;
        security.sudo.wheelNeedsPassword = false;

        environment.shells = [ pkgs.zsh pkgs.bashInteractive ];

        users.users.root.shell = pkgs.zsh;

        programs.zsh.enable = true;
        programs.zsh.ohMyZsh.enable = true;
        programs.zsh.ohMyZsh.theme = "gentoo";
        programs.zsh.ohMyZsh.plugins = [ "git" "docker" "sudo" "fzf" ];
    }
]; }

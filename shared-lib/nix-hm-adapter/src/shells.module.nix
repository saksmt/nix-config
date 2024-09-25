let
  defineOpts =
    lib: with lib; {
      shells = {
        bash = {
          enable = mkEnableOption "bash";
        };
        zsh = {
          enable = mkEnableOption "zsh";
          oh-my-zsh = {
            enable = mkEnableOption "oh-my-zsh";
            plugins = mkOption {
              default = [ ];
              type = types.listOf types.string;
              description = "List of plugins to enable in oh-my-zsh";
            };
            theme = mkOption {
              default = "gentoo";
              type = types.string;
              description = "Theme for oh-my-zsh";
            };
          };
          rc-extra = {
            top = mkOption {
              default = "";
              type = types.lines;
              description = "Extra code to add in .zshrc to the top of the file";
            };
            bottom = mkOption {
              default = "";
              type = types.lines;
              description = "Extra code to add in .zshrc to the bottom of the file";
            };
          };
        };
      };
    };
in
{
  nixosModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options = defineOpts lib;
      config.environment.shells = [
        (lib.mkIf config.shells.bash.enable pkgs.bashInteractive)
        (lib.mkIf config.shells.zsh.enable pkgs.zsh)
      ];

      config.programs.zsh.enable = lib.mkDefault config.shells.zsh.enable;
      # loosely matches "top" of rc file
      config.programs.zsh.interactiveShellInit = config.shells.zsh.rc-extra.top;
      # loosely matches "bottom" of rc file
      config.programs.zsh.promptInit = config.shells.zsh.rc-extra.bottom;
      config.programs.zsh.ohMyZsh.enable = lib.mkDefault config.shells.zsh.oh-my-zsh.enable;
      config.programs.zsh.ohMyZsh.theme = lib.mkDefault config.shells.zsh.oh-my-zsh.theme;
      config.programs.zsh.ohMyZsh.plugins = config.shells.zsh.oh-my-zsh.plugins;
    };
  homeManagerModule =
    { config, lib, ... }:
    {
      options = defineOpts lib;

      config.programs.bash.enable = lib.mkDefault config.shells.bash.enable;

      config.programs.zsh.enable = lib.mkDefault config.shells.zsh.enable;
      config.programs.zsh.initExtraFirst = config.shells.zsh.rc-extra.top;
      config.programs.zsh.initExtra = config.shells.zsh.rc-extra.bottom;
      config.programs.zsh.oh-my-zsh.enable = lib.mkDefault config.shells.zsh.oh-my-zsh.enable;
      config.programs.zsh.oh-my-zsh.theme = lib.mkDefault config.shells.zsh.oh-my-zsh.theme;
      config.programs.zsh.oh-my-zsh.plugins = config.shells.zsh.oh-my-zsh.plugins;
    };
}

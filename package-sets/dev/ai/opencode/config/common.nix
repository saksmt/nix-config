{
  features,
  lib,
  config,
  ...
}:
with features;
let
  forFeature = feature: lib.optionalAttrs feature.isEnabled;
in
forFeature dev.common {
  opencode.confd."000-shared/base" = {
    agent.octto.disable = true;
    share = "disabled";
    autoupdate = false;
    disabled_providers = [ ];
    server = {
      # 77 - ASCII for "M"
      port = 1177;
      # forcing binding only to localhost
      hostname = "127.0.0.1";
    };
  };

  opencode.tui = {
    theme = "catppuccin-${config.catppuccin.flavor}";
    keybinds = {
      app_exit = "ctrl+d";
      session_list = "ctrl+e";
      session_interrupt = "ctrl+c";
      model_list = "ctrl+m"; # <-- this may break;
      variant_list = "ctrl+shift+m";
      agent_list = "ctrl+space";
      status_view = "<leader>s";
      tool_details = "<leader>t";
      theme_list = "none";
    };
  };
}

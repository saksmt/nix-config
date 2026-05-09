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
    agent = {
      octto.disable = true;
      plan.permission =
        let
          planPaths = {
            "./**/plans/**" = "allow";
            "./**/plan/**" = "allow";
            "./**/brainstorming/**" = "allow";
            "./**/thoughts/**" = "allow";
            "./**/notes/**" = "allow";
            "./**/drafts/**" = "allow";
            "./**/ideas/**" = "allow";
            "./**/thought/**" = "allow";
            "./**/note/**" = "allow";
            "./**/draft/**" = "allow";
            "./**/idea/**" = "allow";
            "./**/specs/**" = "allow";
            "./**/spec/**" = "allow";
            "./**/specification/**" = "allow";
            "./**/specifications/**" = "allow";
            "./**/handoff/**" = "allow";
          };
        in
        {
          edit = planPaths;
          write = planPaths;
          submit_plan = "allow";
          create_brainstorm = "allow";
          await_brainstorm_complete = "allow";
          end_brainstorm = "allow";
        };
        plan.tools = {
          submit_plan = true;
          create_brainstorm = true;
          await_brainstorm_complete = true;
          end_brainstorm = true;
        };
    };
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

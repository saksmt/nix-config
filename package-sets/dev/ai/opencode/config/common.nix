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
      octto = lib.mkIf config.opencode.plugins.octto.enable { disable = true; };
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
        };
      plan.tools = {
        submit_plan = true;
        create_brainstorm = lib.mkIf config.opencode.plugins.octto.enable true;
        await_brainstorm_complete = lib.mkIf config.opencode.plugins.octto.enable true;
        end_brainstorm = lib.mkIf config.opencode.plugins.octto.enable true;
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
    instructions = [
      "AGENTS.local.md"
      "AGENTS.md"
    ];
  };

  opencode.tui = {
    theme = "catppuccin-${config.catppuccin.flavor}";
    keybinds = {
      app_exit = "ctrl+d";
      session_list = "ctrl+e";
      session_interrupt = "ctrl+c";
      model_list = "ctrl+m";
      variant_list = "ctrl+shift+m";
      agent_list = "ctrl+space";
      status_view = "<leader>s";
      tool_details = "<leader>t";
      editor_open = "<leader>ctrl+e";
      theme_list = "none";
      command_list = "ctrl+shift+a";

      # fix home/end and ctrl navigation/selection
      input_line_home = "home";
      input_line_end = "end";
      input_select_word_forward = "ctrl+shift+right";
      input_select_word_backward = "ctrl+shift+left";
      input_select_line_home = "shift+home";
      input_select_line_end = "shift+end";

      input_buffer_home = "ctrl+home";
      input_buffer_end = "ctrl+end";
      input_select_buffer_home = "ctrl+shift+home";
      input_select_buffer_end = "ctrl+shift+end";
      input_select_all = "ctrl+a";

      messages_first = "alt+home";
      messages_last = "alt+end";
      messages_previous = "alt+up";
      messages_next = "alt+down";

      prompt_stash = "ctrl+q";
      prompt_stash_list = "ctrl+t";

      prompt_submit = "ctrl+return";
      input_newline = "shift+return";

      terminal_suspend = "alt+z";
      input_undo = "ctrl+z";
      input_redo = "ctrl+shift+z";

      input_delete = "delete";
      input_delete_line = "shift+delete";
    };
  };
}

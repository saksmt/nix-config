{ pkgs, lib, ... }:
let
  enabledLayouts = [
    "traditional"
    "bsp"
    "stack"
    "scrolling"
#    "floating"
  ];
  enabledAsJson = "[${builtins.concatStringsSep ", " (builtins.map (x: ''"${x}"'') enabledLayouts)}]";
  workspaceSwitcher = pkgs.writeShellScriptBin "rift-switch-layout" ''
    increment="1"
    if [[ "$1" == "prev" ]]; then
      increment="-1"
    fi
    rift-cli execute workspace set-layout "$(\
      rift-cli query workspace-layout | \
        jq '.[] | select(.is_active) | .layout_mode' | \
        jq -r 'def layouts:${enabledAsJson}; . as $current | layouts[((layouts | length) + ('$increment') + (layouts | index($current))) % (layouts | length)]' \
    )"
  '';
  windowSwitcher = pkgs.writeShellScriptBin "rift-switch-window" ''
    increment="$1"

    current="$(rift-cli query windows | jq '.[] | select(.is_focused) | .window_server_id')"

    rift-cli execute window focus --window-id "$(rift-cli query windows \
    | jq 'map({ window_server_id, id }) | sort_by(.id)' \
    | jq '. as $all | (map(.window_server_id) | index('$current')) as $current | $all[(($all | length) + ('$increment') + $current) % ($all | length)]' \
    | jq -c '.id' \
    )"
  '';
in
{
  # acsandmann/tap/rift
  # rift service install
  # rift service start
  # rift service stop
  # rift service restart
  # rift-cli

  module-for = [ "hm" ];

  install.packages = [
    pkgs.rift-wm
    workspaceSwitcher
    windowSwitcher
  ];

  xdg.configFile."rift/config.toml" = {
    enable = true;
    text = ''
      [settings]
      animate = false
      default_disable = false
      mouse_follows_focus = true
      mouse_hides_on_focus = false
      focus_follows_mouse = true

      [settings.layout.gaps.inner]
      horizontal = 5
      vertical = 5

      [settings.ui.menu_bar]
      enabled = true
      show_empty = true

      [settings.ui.stack_line]
      enabled = false # does not work properly
      vert_placement = "right"

      [settings.layout]
      mode = "${builtins.head enabledLayouts}"

      [settings.layout.stack]
      stack_offset = 0 # essentially "max" layout of awesomewm

      [virtual_workspaces]
      default_workspace_count = 9
      default_workspace = 0
      reapply_app_rules_on_title_change = true

      [modifier_combinations]
      modkey = "Cmd"

      [keys]
      ${builtins.concatStringsSep "\n" (builtins.map (idx: ''
        "modkey + ${builtins.toString idx}" = { switch_to_workspace = ${builtins.toString (idx - 1)} }
        "modkey + Alt + ${builtins.toString idx}" = { switch_to_workspace = ${builtins.toString (idx - 1)} }
        "modkey + Shift + ${builtins.toString idx}" = { move_window_to_workspace = ${builtins.toString (idx - 1)} }
        "modkey + Alt + Shift + ${builtins.toString idx}" = { move_window_to_workspace = ${builtins.toString (idx - 1)} }
      '') (lib.range 1 9))}
      "modkey + Enter" = { exec = [ "${pkgs.kitty}/bin/kitty", "-d", "~" ] }
      "Alt + Tab" = { exec = [ "${windowSwitcher}/bin/rift-switch-window" ] }
      "Alt + Shift + Tab" = { exec = [ "${windowSwitcher}/bin/rift-switch-window" ] }
      "modkey + Shift + C" = "close_window"
      "modkey + Alt + F" = "toggle_window_floating"
      "modkey + F11" = "toggle_fullscreen"
      "modkey + Slash" = "toggle_orientation"

      "modkey + Space" = { exec = [ "${workspaceSwitcher}/bin/rift-switch-layout" ] }
      "modkey + Shift + Space" = { exec = [ "${workspaceSwitcher}/bin/rift-switch-layout", "prev" ] }
    '';
  };
  #  home.activation.riftwm = lib.hm.dag.entryAfter ["writeBoundary"] "rift service install";
}

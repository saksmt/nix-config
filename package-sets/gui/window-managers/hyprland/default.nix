{
  features,
  pkgs,
  lib,
  config,
  ...
}:

{
  module-for = [ "hm" ];
}
// (
  if features.GUI.isEnabled then
    {
      imports = [ ../barebones/wayland.nix ];

      install.packages = [
        pkgs.lua
        pkgs.rofi
      ];

      services.clipcat.enable = lib.mkDefault true;

      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;

        # managed through nixos
        package = null;
        portalPackage = null;

        configType = "lua";

        extraConfig = ''
        local mod = "SUPER"

        -- ---------------------------------------------------------------------------
        -- Core config
        -- ---------------------------------------------------------------------------

        hl.config({
          general = {
            layout = "dwindle",
          },
          input = {
            -- us first => binds are resolved against the us keymap and keep working
            -- regardless of the active layout (mirrors awesome's keycode-based binds).
            kb_layout = "us,ru",
            kb_options = "grp:alt_shift_toggle",
            follow_mouse = 1,
            mouse_refocus = true,
            focus_on_close = 1,
          },
        })

        -- ---------------------------------------------------------------------------
        -- Workspaces 1-9 with default layouts (awesome per-tag layout -> hyprland)
        --   tile/fair -> dwindle, max -> monocle
        -- ---------------------------------------------------------------------------

        local function default_layout(id, layout)
          hl.workspace_rule({ workspace = tostring(id), layout = layout, persistent = true })
        end

        default_layout(1, "dwindle")
        default_layout(2, "monocle")
        default_layout(3, "monocle")
        default_layout(4, "monocle")
        default_layout(5, "dwindle")
        default_layout(6, "dwindle")
        default_layout(7, "dwindle")
        default_layout(8, "monocle")
        default_layout(9, "monocle")

        -- ---------------------------------------------------------------------------
        -- Window rules
        -- ---------------------------------------------------------------------------

        hl.window_rule({ match = { class = "pinentry" }, float = true, center = true, stay_focused = true })
        hl.window_rule({ match = { class = "copyq" }, float = true })

        -- ---------------------------------------------------------------------------
        -- Layout cycling (Super+Space / Super+Shift+Space)
        -- ---------------------------------------------------------------------------

        local layouts = { "dwindle", "monocle" }

        local function cycle_layout(dir)
          dir = dir or 1
          local ws = hl.get_active_workspace()
          if not ws then
            return
          end

          local next = layouts[1]
          for i, name in ipairs(layouts) do
            if name == ws.tiled_layout then
              local idx = i + dir
              if idx < 1 then idx = #layouts end
              if idx > #layouts then idx = 1 end
              next = layouts[idx]
              break
            end
          end

          hl.workspace_rule({ workspace = "name:" .. tostring(ws.name), layout = next })
        end

        -- ---------------------------------------------------------------------------
        -- Keybindings
        -- ---------------------------------------------------------------------------

        -- workspaces
        for i = 1, 9 do
          hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
          hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
        end

        -- focus / swap
        hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }))
        hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))
        hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }))
        hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }))

        hl.bind(mod .. " + ALT + left", hl.dsp.window.swap({ direction = "l" }))
        hl.bind(mod .. " + ALT + right", hl.dsp.window.swap({ direction = "r" }))
        hl.bind(mod .. " + ALT + up", hl.dsp.window.swap({ direction = "u" }))
        hl.bind(mod .. " + ALT + down", hl.dsp.window.swap({ direction = "d" }))

        hl.bind(mod .. " + CTRL + left", hl.dsp.focus({ monitor = "l" }))
        hl.bind(mod .. " + CTRL + right", hl.dsp.focus({ monitor = "r" }))
        hl.bind(mod .. " + CTRL + up", hl.dsp.focus({ monitor = "u" }))
        hl.bind(mod .. " + CTRL + down", hl.dsp.focus({ monitor = "d" }))

        -- window cycling (alt-tab), current workspace only, works in dwindle + monocle.
        -- backward (shift+tab) is intentionally omitted: alt+shift is the layout toggle.
        hl.bind("ALT + tab", hl.dsp.window.cycle_next({ tiled = true }))

        -- launchers
        hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
        hl.bind(mod .. " + R", hl.dsp.exec_cmd("rofi -show drun"))
        hl.bind(mod .. " + P", hl.dsp.exec_cmd("rofi -show combi"))
        hl.bind(mod .. " + W", hl.dsp.exec_cmd("rofi -show window"))

        -- layout
        hl.bind(mod .. " + SPACE", function()
          cycle_layout(1)
        end)
        hl.bind(mod .. " + SHIFT + SPACE", function()
          cycle_layout(-1)
        end)

        -- client manipulation
        hl.bind(mod .. " + SHIFT + C", hl.dsp.window.close())
        hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
        -- E and M are equivalent under Hyprland (maximize keeps gaps/bar and avoids
        -- browser presentation mode).
        hl.bind(mod .. " + E", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
        hl.bind(mod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
        hl.bind(mod .. " + CTRL + SPACE", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mod .. " + O", hl.dsp.window.move({ monitor = "+1" }))

        -- session
        hl.bind(mod .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"))
        hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())

        -- mouse (move / resize)
        hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
        hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

        '';
      };
    }
  else
    { }
)

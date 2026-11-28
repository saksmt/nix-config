{ lib, config, ... }: let os-config = config; in {
  module-for = [ "nixos" ];

  imports = [
    (import ../../../gui/setup/hyprland.nix)
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = lib.mkDefault "1";
    MOZ_ENABLE_WAYLAND = lib.mkDefault "1";
    ELECTRON_OZONE_PLATFORM_HINT = lib.mkDefault "auto";
  };

  hardware.uinput.enable = true;
  users.users.potato.extraGroups = [ "uinput" ];
  programs.steam.enable = lib.mkDefault true;
  programs.steam.extest.enable = true;

  services.displayManager.defaultSession = "hyprland";
  home-manager.users.${os-config.environment.couch-potato.user.name} = { pkgs, config, ... }: {
    xdg.configFile."uwsm/env".source =
      "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;

      # managed through nixos
      package = null;
      portalPackage = null;

      configType = "lua";
      extraConfig =
        let
          launchSteam = pkgs.writeShellScript "couch-steam" ''
            steam -tenfoot -gamepadui -pipewire-dmabuf
            # line below is only called when steam exits entirely
            uwsm stop
          '';
          toLua = lib.generators.toLua {};
        in
        ''
          local steam_launcher = ${toLua launchSteam}
          local outputs = ${toLua os-config.environment.couch-potato.outputs};
          local active_output = nil

          local function format_mode(out)
            if out.resolution and out['refresh-rate'] then
              return out.resolution .. "@" .. tostring(out.refresh_rate)
            elseif out.resolution then
              return out.resolution
            else
              return "preferred"
            end
          end

          local function sync_outputs()
            -- { all = true } includes physically connected outputs that are currently disabled
            local monitors = hl.get_monitors({ all = true })
            local connected = {}
            for _, m in ipairs(monitors) do
              connected[m.name] = true
            end

            -- Pick highest-priority connected output
            local chosen = nil
            for _, out in ipairs(outputs) do
              if connected[out.name] then
                chosen = out
                break
              end
            end

            if not chosen or chosen.name == active_output then
              return
            end

            -- Enable chosen output first so Hyprland never has 0 active monitors
            hl.monitor({
              output = chosen.name,
              disabled = false,
              mode = format_mode(chosen),
              position = "0x0",
              scale = 1,
              bitdepth = chosen.hdr and 10 or 8,
              supports_hdr = chosen.hdr and 0 or -1, -- 0 = auto, -1 = off
              vrr = chosen.vrr and 2 or 0,           -- 2 = fullscreen only, 0 = off
            })

            -- Disable every other connected output
            for name, _ in pairs(connected) do
              if name ~= chosen.name then
                hl.monitor({ output = name, disabled = true })
              end
            end

            active_output = chosen.name
            hl.dispatch(hl.dsp.focus({ workspace = "1" }))
          end

          local any_with_hdr = false
          for _, output in ipairs(outputs) do
            if output.hdr then
              any_with_hdr = true
              break
            end
          end

          local any_with_vrr = false
          for _, output in ipairs(outputs) do
            if output.vrr then
              any_with_vrr = true
              break
            end
          end

          hl.config({
            render = {
              cm_enabled = true,
              cm_auto_hdr = any_with_hdr and 1 or 0,
            },
            general = {
              gaps_in = 0,
              gaps_out = 0,
              border_size = 0,
            },
            input = {
              -- todo: unhardcode
              kb_layout = "us,ru",
              kb_options = "grp:alt_shift_toggle",
            },
            decoration = {
              rounding = 0,
            },
            animations = {
              enabled = false,
            },
            cursor = {
              inactive_timeout = 3,
            },
            misc = {
              disable_hyprland_logo = true,
              disable_splash_rendering = true,
              vrr = any_with_vrr and 1 or 0,
              focus_on_activate = true,
              on_focus_under_fullscreen = 1,
            },
            ecosystem = {
              no_update_news = true,
              no_donation_nag = true,
            },
          })
          hl.window_rule({
            name = "steam-bpm-maximize",
            match = { class = "^steam$", title = "^Steam Big Picture Mode$" },
            suppress_event = "fullscreen",
            maximize = true,
          })

          hl.window_rule({
            match = { class = ".*" },
            workspace = "1",
          })
          hl.on("workspace.active", function (ws)
            if ws and ws.id ~= 1 then
              hl.dispatch(hl.dsp.focus({ workspace = "1" }))
            end
          end)
          hl.on("window.move_to_workspace", function(w, ws)
            if ws and ws.id ~= 1 then
              hl.dispatch(hl.dsp.window.move({ window = w, workspace = "1", follow = true }))
            end
          end)

          hl.on("monitor.added", sync_outputs)
          hl.on("monitor.removed", sync_outputs)

          hl.on("hyprland.start", function()
            sync_outputs()
            hl.exec_cmd(steam_launcher)
          end)
        '';
    };
  };
}

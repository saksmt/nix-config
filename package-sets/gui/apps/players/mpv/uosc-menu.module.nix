{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.mpv.uosc;
  jsonFormat = pkgs.formats.json { };
  commonOpts = {
    title = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    hint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    bold = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
    };
    italic = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
    };
    muted = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
    };
    separator = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
    };
    align = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "left"
          "center"
          "right"
        ]
      );
      default = null;
    };
  };
  menuOpts = {
    footnote = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    items = lib.mkOption {
      type = lib.types.listOf menu;
      default = [ ];
    };
  };
  menu = lib.types.attrTag {
    item = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options = commonOpts // {
          value = lib.mkOption { type = lib.types.either (lib.types.str) (lib.types.listOf lib.types.str); };
        };
      };
    };
    submenu = lib.mkOption {
      type = lib.types.submodule {
        options = menuOpts // commonOpts;
      };
      default = { };
    };
  };
in
{
  options.programs.mpv.uosc.menu = lib.mkOption {
    description = "Extra menus for uosc, call via ...";
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = menuOpts // {
          title = commonOpts.title;
          type = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
        };
      }
    );
  };
  options.programs.mpv.uosc.before-main-menu = lib.mkOption {
    default = [ ];
    type = lib.types.listOf menu;
  };
  options.programs.mpv.uosc.after-main-menu = lib.mkOption {
    default = [ ];
    type = lib.types.listOf menu;
  };
  config.programs.mpv.scripts = (
    let
      resolveChildren =
        item:
        if item ? "submenu" then
          item.submenu // { items = resolveChildren item.submenu.items; }
        else
          item.item;
      menuJsons = builtins.mapAttrs (
        name: menu:
        jsonFormat.generate "uosc-menu-${name}.json" (
          menu
          // {
            items = builtins.map resolveChildren menu.items;
          }
        )
      ) cfg.menu;
      beforeMain = jsonFormat.generate "uosc-before-main-menu.json" (
        builtins.map resolveChildren cfg.before-main-menu
      );
      afterMain = jsonFormat.generate "uosc-after-main-menu.json" (
        builtins.map resolveChildren cfg.after-main-menu
      );
      menuScript = pkgs.writeTextFile {
        name = "mpv-extra-uosc-menu";
        destination = "/share/mpv/scripts/extra-uosc-menu.lua";
        passthru.scriptName = "extra-uosc-menu.lua";
        text = ''
          function get_file_contents(path)
            local resolved_path = mp.command_native({ "expand-path", path })
            local file, err = io.open(resolved_path, "r")
            if not file then
              mp.msg.warn("Could not open JSON file (" .. resolved_path .. "): " .. tostring(err))
              return nil
            end

            local content = file:read("*a")
            file:close()
            return content
          end

          local menus = {
            ${builtins.concatStringsSep ",\n" (
              builtins.map (name: ''
                ${name} = get_file_contents('${menuJsons.${name}}')
              '') (builtins.attrNames menuJsons)
            )}
          }
          local utils = require('mp.utils')

          local beforeMain = utils.parse_json(get_file_contents('${beforeMain}'))
          local afterMain = utils.parse_json(get_file_contents('${afterMain}'))

          function concatAll(...)
            local args = table.pack(...)

            local result = {};
            local index = 1;

            for i=1, #args do
              local currentArg = args[i]
              for j=1, #currentArg do
                result[index] = currentArg[j]
                index = index + 1
              end
            end

            return result
          end

          function get_main_menu()
            local menuItems = concatAll(beforeMain, {
              { title = "Open", separator = true, value = { "script-binding", "uosc/open-file" } },
              { title = "Subtitles",     value = { "script-binding", "uosc/subtitles" } },
              { title = "Audio tracks",  value = { "script-binding", "uosc/audio" } },
              { title = "Audio devices", value = { "script-binding", "uosc/audio-device" } },
              { title = "Chapters", separator = true, value = { "script-binding", "uosc/chapters" } },
              { title = "More", items = {
                { title = 'Video tracks', value = { 'script-binding', 'uosc/video' } },
                { title = 'Edition', value = { 'script-binding', 'uosc/editions' } },
                { title = 'Stream quality', value = { 'script-binding', 'uosc/stream-quality' } },
                { title = 'Playlist', value = { 'script-binding', 'uosc/items' } },
                { title = 'Show in directory', value = { 'script-binding', 'uosc/show-in-directory' } },
                { title = 'Playlist/directory shuffle', value = { 'script-binding', 'uosc/shuffle' } }
              } }
            }, afterMain, { { title = "Quit", value = { 'quit' } } })

            print(utils.format_json({
                                   type = "main_menu",
                                   title = "Menu",
                                   items = menuItems
                                 }))
            return utils.format_json({
              type = "main_menu",
              title = "Menu",
              items = menuItems
            })
          end

          mp.register_script_message('open-menu', function (menuName)
            local selected = menus[menuName]
            if selected ~= nil then
               mp.commandv('script-message-to', 'uosc', 'open-menu', selected)
               return
            end

            if menuName == "main" then
              mp.commandv('script-message-to', 'uosc', 'open-menu', get_main_menu())
            end
          end)

          mp.register_script_message('open-file-menu', function (path)
            local resolved_path = mp.command_native({ "expand-path", path })
            mp.commandv('script-message-to', 'uosc', 'open-file-menu', resolved_path)
          end)
        '';
      };
    in
    [ menuScript ]
  );
}

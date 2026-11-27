{
  lib,
  config,
  ...
}:
let
  cfg = config.environment.couch-potato;
in
{
  options.environment.couch-potato = {
    prefer-vk-device = lib.mkOption {
      description = "{id}:{vendor} of preferred GPU, optional; useful only for multi-gpu setups (i.e. realistically - laptops)";
      type = lib.types.nullOr lib.types.str;
      example = "10de:25a0";
      default = null;
    };
    outputs = lib.mkOption {
      description = "list of outputs in order of preference";
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              description = "name of output, MUST BE FROM /sys/class/drm, not from xrandr!";
              type = lib.types.str;
              example = "HDMI-A-1";
            };
            resolution = lib.mkOption {
              description = "resolution in WxH format, leave null for edid preferred";
              type = lib.types.nullOr lib.types.str;
              example = "1280x1024";
            };
            refresh-rate = lib.mkOption {
              description = "refresh rate, leave null for highest available for chosen resolution";
              type = lib.types.nullOr lib.types.ints.positive;
              example = 60;
            };
            hdr = lib.mkOption {
              description = "enable hdr support";
              type = lib.types.bool;
              default = true;
            };
            vrr = lib.mkOption {
              description = "enable vrr support";
              type = lib.types.bool;
              default = true;
            };
          };
        }
      );
    };
  };

  config.programs.gamescope.capSysNice = true;
  config.programs.steam.gamescopeSession = {
    enable = true;
    args =
      (lib.optionals ((builtins.length cfg.outputs) > 0) (
        let
          outputNames = builtins.map (output: output.name) cfg.outputs;
        in
        /*nixfmt:disable*/
        [ "-O" (builtins.concatStringsSep "," outputNames) ]
        /*nixfmt:enable*/
      ))
      ++ (lib.optionals (cfg.prefer-vk-device != null) [
        "--prefer-vk-device"
        cfg.prefer-vk-device
      ])
      ++ [
        "--expose-wayland"
        "--rt"
      ];
    steamArgs = [
      "-tenfoot"
      "-pipewire-dmabuf"
      "-steamos3"
    ];
    env = {
      ENABLE_GAMESCOPE_WSI = "1";
      # used in wrapper, why not package directly? - that will break capSysNice which generates a wrapper
      GAMESCOPE_BIN = "/run/wrappers/bin/gamescope";
    };
  };
}

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

    prefer-vk-device = lib.mkOption {
      description = "{id}:{vendor} of preferred GPU, optional; useful only for multi-gpu setups (i.e. realistically - laptops)";
      type = lib.types.nullOr lib.types.str;
      example = "10de:25a0";
      default = null;
    };
    wlr-drm-devices = lib.mkOption {
      description = "colon separated list of GPU paths, optional; useful only for multi-gpu setups (i.e. realistically - laptops)";
      type = lib.types.nullOr lib.types.str;
      example = "/dev/dri/card1:/dev/dri/card0";
      default = null;
    };
    outputs = lib.mkOption {
      description = "list of hot-pluggable outputs in order of preference";
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
              description = "refresh rate, leave null for default";
              type = lib.types.nullOr lib.types.ints.positive;
              example = 60;
            };
          };
        }
      );
    };
  };

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
      ++ (lib.optional cfg.vrr "--adaptive-sync")
      ++ (lib.optionals cfg.hdr [
        "--hdr-enabled"
        "--hdr-debug-force-output"
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
      WLR_DRM_DEVICES = lib.mkIf (cfg.wlr-drm-devices != null) cfg.wlr-drm-devices;
    };
  };
}

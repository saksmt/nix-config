{
  features,
  lib,
  ...
}:
{
  module-for = [ "hm" ];
  imports = lib.optionals features.GUI.isEnabled [
    (import ./players)
    ({
      programs.mpv = {
        config = {
          vo = "gpu-next";
          gpu-api = "vulkan";
          gpu-context = "auto";
          force-window = "yes";
          target-colorspace-hint = "yes";
        };
      };
    })
  ];
}

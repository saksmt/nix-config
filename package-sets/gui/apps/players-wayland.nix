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
          gpu-context = "waylandvk";
          target-colorspace-hint = "yes";
        };
      };
    })
  ];
}

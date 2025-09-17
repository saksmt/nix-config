{
  features,
  lib,
  pkgs,
  ...
}:

lib.mkMerge [
  {
    module-for = [ "hm" ];
  }

  (features.GUI.whenEnabled {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-freeze-filter
        obs-tuna
        obs-text-pthread
        obs-gradient-source
        obs-rgb-levels
      ];
    };
  })
]

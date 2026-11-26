{
  features,
  pkgs,
  lib,
  config,
  ...
}:
with features;

{
  module-for = [ "hm" ];
  imports = [
    {
      options.programs.moonlight = {
        enable = lib.mkEnableOption "moonlight";
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.moonlight-qt;
        };
      };

      config.install.packages = lib.mkIf config.programs.moonlight.enable [
        config.programs.moonlight.package
      ];
    }
  ];
}
// (lib.optionalAttrs (GUI.and gaming).isEnabled {
  programs.moonlight.enable = true;
})

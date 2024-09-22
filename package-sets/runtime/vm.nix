{ features, ... }:
{
  module-for = [ "nixos" ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.host.headless = features.GUI.isDisabled;
}

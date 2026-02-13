{
  lib,
  features,
  ...
}:
with features;

{
  module-for = [ "nixos" ];

  networking.networkmanager.enable = lib.mkDefault laptop.isEnabled;
  services.upower.enable = lib.mkDefault laptop.isEnabled;

  powerManagement.cpuFreqGovernor = lib.mkOverride 900 (
    if laptop.isEnabled then "ondemand" else "performance"
  );
}

{ pkgs, ... }:
{
  module-for = [ "nixos" ];

  # udev rules
  services.udev.packages = with pkgs; [
    yubikey-personalization
    yubikey-manager
  ];
}

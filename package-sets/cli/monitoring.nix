{ pkgs, lib, ... }:
{
  module-for = [
    "hm"
    "nixos"
  ];

  install.packages = with pkgs; [
    btop
    unixtools.netstat
    iotop
    iftop
    powertop
  ];

  catppuccin.btop.enable = true;
}

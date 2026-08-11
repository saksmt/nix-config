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
    pv
  ];

  catppuccin.btop.enable = true;
}

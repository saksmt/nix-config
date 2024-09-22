{ pkgs, ... }:
{
  module-for = [
    "hm"
    "nixos"
  ];

  install.packages = with pkgs; [
    kubectl
  ];
}

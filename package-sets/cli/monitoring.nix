{ pkgs, lib, ... }:
{
  module-for = [
    "hm"
    "nixos"
  ];

  install.packages =
    with pkgs;
    [
      btop
      unixtools.netstat
      iftop
      pv
    ]
    ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      iotop
      powertop
    ]);

  catppuccin.btop.enable = true;
}

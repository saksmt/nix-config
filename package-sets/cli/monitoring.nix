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
      powertop
      pv
    ]
    ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      iotop
    ]);

  catppuccin.btop.enable = true;
}

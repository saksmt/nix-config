{
  pkgs,
  features,
  lib,
  ...
}:
with features;
{
  module-for = [
    "hm"
    "nixos"
  ];

  install.packages =
    with pkgs;
    lib.lists.optionals dev.nix.isEnabled [
      nil
      nixfmt-rfc-style
    ];
}

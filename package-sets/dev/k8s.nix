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
    lib.lists.optionals dev.k8s.isEnabled [
      kubectl
      helm
      kind
    ];
}

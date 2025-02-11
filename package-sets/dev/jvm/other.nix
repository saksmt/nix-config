{
  pkgs,
  features,
  lib,
  config,
  ...
}:
with features;
{
  module-for = [
    "hm"
    "nixos"
  ];

  programs.java.enable = dev.jvm-other.isEnabled;
  install.packages =
    with pkgs;
    lib.lists.optionals dev.jvm-other.isEnabled [
      (maven.override { jdk_headless = config.programs.java.package; })
    ];
}

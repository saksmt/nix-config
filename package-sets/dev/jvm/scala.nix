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

  programs.java.enable = dev.scala.isEnabled;
  install.packages =
    with pkgs;
    lib.lists.optionals dev.scala.isEnabled [
      (sbt.override { jre = config.programs.java.package; })
      (scala-cli.override { jre = config.programs.java.package; })
      (scalafmt.override { jre = config.programs.java.package; })
    ];
}

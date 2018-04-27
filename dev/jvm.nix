{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
    scala
    sbt
    oraclejdk
    gradle
  ];
}

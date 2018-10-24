{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  programs.java.package = pkgs.oraclejdk;
  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
    scala
    sbt
    oraclejdk
    gradle
  ];
}

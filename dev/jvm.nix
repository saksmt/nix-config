{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
    oracle-instantclient
    sqldeveloper
    scala
    sbt
    oraclejdk
    gradle
  ];
}

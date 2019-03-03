{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

# todo: idea to NotNoX, maybe split dev from runtime
whenDev {
  nixpkgs.config.oraclejdk.accept_license = true;
  nixpkgs.config.allowUnfree = true;
  programs.java.package = pkgs.oraclejdk;
  nixpkgs.config.oraclejdk.accept_license = true;
  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
    scala
    sbt
    oraclejdk
    gradle
  ];
}

{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

# todo: idea to NotNoX, maybe split dev from runtime
whenDev {
  nixpkgs.config.oraclejdk.accept_license = true;
  nixpkgs.config.allowUnfree = true;
  programs.java.package = pkgs.jdk11;
  environment.systemPackages = with pkgs; [
    unstable.jetbrains.idea-ultimate
    scala
    sbt
    bloop
    jdk
    gradle
    freshBazel
  ];
}

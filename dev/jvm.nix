{ whenDev, ... }: { config, pkgs, ... }:

# todo: idea to NotNoX, maybe split dev from runtime
whenDev {
  nixpkgs.config.oraclejdk.accept_license = true;
  nixpkgs.config.allowUnfree = true;
  programs.java.package = pkgs.jdk11;
  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
    scala
    sbt
    bloop
    jdk
    gradle
    bazel
    mill
  ];
}

{ whenDev, ... }: { config, pkgs, ... }:

# todo: idea to NotNoX, maybe split dev from runtime
whenDev {
  nixpkgs.config.packageOverrides = pkgs: rec {
    sbt = pkgs.sbt.override {
      jre = pkgs.jdk11;
    };
  };

  nixpkgs.config.allowUnfree = true;
  programs.java.package = pkgs.jdk11;
  environment.systemPackages = with pkgs; [
    pkgs.jetbrains.idea-ultimate
    scala
    sbt
    bloop
    jdk11
    gradle
    bazel
    mill
  ];
}

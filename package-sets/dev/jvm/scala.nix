{
  pkgs,
  features,
  lib,
  config,
  jail,
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
    lib.lists.optionals dev.scala.isEnabled (
      [
        (scala-cli.override { jre = config.programs.java.package; })
        (scalafmt.override { jre = config.programs.java.package; })
      ]
      ++ (
        let
          unjailed-sbt = sbt.override { jre = config.programs.java.package; };
          jailed-sbt = jail "jailed-sbt-client" "sbt" (
            with jail.combinators;
            [
              transparent
              network
              host-nix-store
              git-config
              xdg
              base-linux-utils
              terminfo

              (add-pkg-deps ([
                unjailed-sbt
                config.programs.java.package
              ]))
              (set-argv [
                "--client"
                (noescape "\"$@\"")
              ])

              (try-readwrite (noescape "~/.sbt"))
              (try-readwrite (noescape "~/.cache/coursier"))
              (try-readwrite (noescape "~/.m2"))
              (try-readwrite (noescape "~/.ivy2"))
            ]
          );
        in
        [
          unjailed-sbt
          jailed-sbt
        ]
      )
    );
}

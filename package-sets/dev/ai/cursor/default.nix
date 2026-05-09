{
  pkgs,
  features,
  lib,
  jail,
  config,
  ...
}:
with features;
let
  jailed =
    name: pkg:
    jail "jailed-${name}" pkg (
      with jail.combinators;
      [
        transparent
        network
        host-nix-store
        (add-pkg-deps [ pkgs.git ])
        git-config
        xdg
        modern-linux-utils
        base-linux-utils
        terminfo

        (try-readwrite (noescape "~/.cursor"))
        (try-readwrite (noescape "~/.cursor-server"))
        (try-readwrite (noescape "~/.config/cursor"))
        (try-readwrite (noescape "~/.config/Cursor"))
        (try-readwrite (noescape "~/.local/share/Cursor"))
        (try-readwrite (noescape "~/.local/share/cursor-agent"))
        (try-readwrite (noescape "~/.cache/Cursor"))

        # sbt stuff
        # this is why this approach does not scale...
        (add-pkg-deps ([
          (pkgs.sbt.override { jre = config.programs.java.package; })
          config.programs.java.package
        ]))
        (try-readwrite (noescape "~/.sbt"))
        (try-readwrite (noescape "~/.cache/coursier"))
        (try-readwrite (noescape "~/.m2"))
        (try-readwrite (noescape "~/.ivy2"))
      ]
    );
in
{
  module-for = [
    "hm"
  ];

  install.packages =
    with pkgs;
    lib.lists.optionals work.isEnabled (
      [
        (jailed "cursor-agent" cursor-cli)
        cursor-cli
      ]
      ++ (lib.lists.optionals GUI.isEnabled [
        (jailed "cursor" code-cursor)
        code-cursor
      ])
    );
}

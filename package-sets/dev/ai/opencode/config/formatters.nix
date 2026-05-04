{
  features,
  pkgs,
  lib,
  ...
}:
with features;
let
  forFeature = feature: lib.optionalAttrs feature.isEnabled;
  merge = builtins.foldl' (a: b: a // b) { };
in
forFeature dev.common {
  opencode.confd."000-shared/formatters".formatter = merge [
    (forFeature dev.scala {
      scalafmt = {
        command = [
          "${pkgs.scalafmt}/bin/scalafmt"
          "$FILE"
        ];
        extensions = [
          ".scala"
          ".sbt"
        ];
      };
    })
    (forFeature dev.nix {
      nixfmt = {
        command = [
          "${pkgs.nixfmt-rfc-style}/bin/nixfmt"
          "$FILE"
        ];
        extensions = [
          ".nix"
        ];
      };
    })
    (forFeature dev.common {
      shfmt = {
        command = [
          "${pkgs.shfmt}/bin/shfmt"
          "$FILE"
        ];
        #todo: check if it is possible to rely on shebang
        extensions = [
          ".sh"
          ".bash"
        ];
      };
    })
    (forFeature dev.haskell {
      ormolu = {
        command = [
          "${pkgs.ormolu}/bin/ormolu"
          "--mode"
          "inplace"
          "$FILE"
        ];
        extensions = [
          ".hs"
        ];
      };
    })
    # todo: wrapper for jqfmt
  ];
}

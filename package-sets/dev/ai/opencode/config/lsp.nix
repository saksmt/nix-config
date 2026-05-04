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
  opencode.confd."000-shared/lsp".lsp = merge [
    (forFeature dev.nix {
      nixd = {
        command = [
          "${pkgs.nixd}/bin/nixd"
        ];
        extensions = [
          ".nix"
        ];
      };
    })
    (forFeature dev.haskell {
      hls = {
        command = [
          "${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper"
          "--lsp"
        ];
        extensions = [
          ".hs"
        ];
      };
    })
    (forFeature dev.common {
      bash = {
        command = [
          "${pkgs.bash-language-server}/bin/bash-language-server"
          "start"
        ];
        extensions = [
          ".sh"
        ];
      };
    })
    (forFeature dev.common {
      jqlsp = {
        command = [
          "${pkgs.jq-lsp}/bin/jq-lsp"
        ];
        extensions = [
          ".jq"
        ];
      };
    })
  ];
}

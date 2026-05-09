{
  pkgs,
  features,
  lib,
  ...
}:
with features;
{
  module-for = [
    "hm"
  ];

  install.packages =
    with pkgs;
    lib.lists.optionals dev.common.isEnabled (
      [
        mcp-wrapper

        gemini-cli
      ]
      ++ (lib.lists.optionals work.isEnabled [
        codex
      ])
    );
}

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
    "nixos"
  ];

  install.packages =
    with pkgs;
    lib.lists.optionals dev.common.isEnabled ([
      mcp-wrapper

      gemini-cli
      code-cursor
      cursor-cli
      opencode
      opencode-desktop
      codex
    ]);
}

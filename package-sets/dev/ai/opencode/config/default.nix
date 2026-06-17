_: {
  imports = [
    (import ./common.nix)
    (import ./formatters.nix)
    (import ./lsp.nix)
    (import ./mcp.nix)
    (import ./plugins)
  ];
}
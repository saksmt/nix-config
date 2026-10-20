_: {
  imports = [
    (import ./common.nix)
    (import ./agents.hm.module.nix)
    (import ./magicless-agents.nix)
    (import ./formatters.nix)
    (import ./lsp.nix)
    (import ./mcp.nix)
    (import ./plugins)
  ];
}
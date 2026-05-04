_: {
  imports = [
    (import ./common.nix)
    (import ./dcp.nix)
    (import ./notifier.nix)
    (import ./mem.nix)
    (import ./octto.nix)
  ];
}

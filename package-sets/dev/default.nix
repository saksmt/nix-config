_: {
  imports = [
    # ai intentionally omitted - it mostly requires home manager
    (import ./common.nix)
    (import ./haskell.nix)
    (import ./k8s.nix)
    (import ./nix.nix)
    (import ./jvm/other.nix)
    (import ./jvm/scala.nix)
  ];
}

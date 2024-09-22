_: {
  imports = [
    (import ./common.nix)
    (import ./haskell.nix)
    (import ./k8s.nix)
    (import ./nix.nix)
    (import ./jvm/other.nix)
    (import ./jvm/scala.nix)
  ];
}
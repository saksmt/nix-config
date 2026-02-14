_: {
  imports = [
    (import ./media.nix)
    (import ./quality-of-life.nix)
    (import ./monitoring.nix)
    (import ./work.nix)
    (import ./for-interactive-environments.nix)
  ];
}

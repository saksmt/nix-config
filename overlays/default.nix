inputs: nixpkgs:
(import ./external.nix inputs nixpkgs)
++ [
  (import ./custom-packages.nix inputs nixpkgs)
]

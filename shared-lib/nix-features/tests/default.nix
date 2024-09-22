nixpkgs:
builtins.foldl' (a: b: a // b) { } (
  builtins.map (p: import p nixpkgs) [

    ./as-lib.test.nix
    ./private-lib.test.nix

  ]
)

_: {
  imports = [
    (import ./package.nix)
    (import ./hm.module.nix)
    (import ./config)
  ];
}
_: {
  imports = [
    (import ./bluetooth.nix)
    (import ./guitar.nix)
    (import ./keyboard.nix)
    (import ./yubikey.nix)
  ];
}

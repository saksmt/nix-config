_: {
  imports = [
    (import ./android.nix)
    (import ./bluetooth.nix)
    (import ./guitar.nix)
    (import ./keyboard.nix)
    (import ./yubikey.nix)
  ];
}

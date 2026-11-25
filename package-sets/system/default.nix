_: {
  imports = [
    (import ./gaming-setup.nix)
    (import ./base.nix)
    (import ./laptop.nix)
    (import ./virtual-camera.nix)
    (import ./hardware)
  ];
}

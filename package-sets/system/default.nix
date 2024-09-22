_: {
  imports = [
    (import ./boot.nix)
    (import ./gaming-setup.nix)
    (import ./system.nix)
    (import ./virtual-camera.nix)
    (import ./hardware)
  ];
}

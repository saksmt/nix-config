{ features, lib, ... }: {
  imports = lib.optionals features.GUI.isEnabled [
    (import ./staged-seek.nix)
    (import ./uosc-menu.module.nix)
    (import ./settings.nix)
  ];
}

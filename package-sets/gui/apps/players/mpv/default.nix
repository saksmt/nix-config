{ features, lib, ... }: {
  imports = lib.optionals features.GUI.isEnabled [
    (import ./staged-seek.nix)
    (import ./smart-track-selection.nix)
    (import ./uosc-menu.module.nix)
    (import ./settings.nix)
  ];
}

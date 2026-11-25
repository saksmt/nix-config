{ features, lib, ... }: {
  imports = lib.optionals features.GUI.isEnabled [
    (import ./mpv)
    (import ./others.nix)
  ];
}

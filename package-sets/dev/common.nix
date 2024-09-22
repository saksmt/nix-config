{
  pkgs,
  features,
  lib,
  ...
}:
with features;
{
  module-for = [
    "hm"
    "nixos"
  ];

  install.packages =
    with pkgs;
    lib.lists.optionals dev.common.isEnabled (
      [
        graphviz
        httpie
      ]
    );
  services.emacs.enable = lib.mkDefault dev.common.isEnabled;
  services.emacs.defaultEditor = lib.mkDefault dev.common.isEnabled;
  services.emacs.package = if GUI.isEnabled then pkgs.emacs else (pkgs.emacs.override {
    noGui = true;
  });
}

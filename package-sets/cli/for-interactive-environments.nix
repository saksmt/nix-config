# for environments where direct user interaction is intended (i.e end-user PC, laptop, ...)
{
  pkgs,
  features,
  lib,
  ...
}:
{
  module-for = [
    "hm"
    "nixos"
  ];

  install.packages =
    with pkgs;
    (lib.lists.optionals features.GUI.isEnabled [
      (hunspell.withDicts (dicts: [
        dicts.ru_RU
        dicts.en_US-large
      ]))

      # these archive types are not strictly needed and almost always
      # imply something user-downloaded in interactive environment
      p7zip
      rar
    ]);
}

# for environments where direct user interaction is intended (i.e end-user PC, laptop, ...)
{ pkgs, features, lib, ... }: {
  module-for = [
    "hm"
    "nixos"
  ];

  install.packages = with pkgs; lib.lists.optionals features.GUI.isEnabled [
    (hunspellWithDicts [
      hunspellDicts.ru_RU
      hunspellDicts.en_US-large
    ])
  ];
}
{ utils, ... }:
recipe-loader:
let
  isoFromInstallationModulesFor =
    system: path:
    (recipe-loader.load-and-process {
      modules = [ "/installation-modules/iso" ];
      recipe-path = path;
    }).as-iso
      system;
in
(utils.lib.eachDefaultSystem (
  system:
  let
    mkIso = isoFromInstallationModulesFor system;
  in
  {
    isos = {

      full-fat = mkIso "/hosts/iso/full-fat.nix";
      nox = mkIso "/hosts/iso/nox.nix";
      grub-test = mkIso "/hosts/iso/grub-test.nix";

    };
  }
)).isos

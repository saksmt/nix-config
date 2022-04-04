{ config, pkgs, lib, ... }:


with lib;

let

  refindBuilder = pkgs.substituteAll {
    src = ./refind-builder.py;

    isExecutable = true;

    nix = "/nix/store/fc33jq7fj9vi7nj7vmy69hj6igy7mgyp-nix-2.3.16";

    inherit (pkgs) python3;

    timeout = "";

    extraConfig = "";

    extraConfigFile = "";

    themes = {
      minimal = "";
    };

    menuEntryConfig = {
      icon = ""
      format = ""
      dateFormat = ""
      extraOptions = ""
    }

    subMenuEntryConfig = {
      dateFormat = ""
      format = "{generation} {relativeGeneration} {date} {kernelVersion} {nixosSemVer} {nixosFullVer}"
    }

    canTouchEfiVariables = true;

    efiSysMountPoint = "/home/smt/tmp/tst-refind/out";

    inherit (pkgs) refind efibootmgr coreutils gnugrep gnused gawk utillinux;
  };

in {
  inherit refindBuilder;
}
{ lib, pkgs, ... }:
let
  script = pkgs.stdenv.mkDerivation {
    name = "mpv-smart-track-selection";
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/share/mpv/scripts
      cp ${./smart-track-selection.lua} $out/share/mpv/scripts/smart-track-selection.lua
    '';

    passthru.scriptName = "smart-track-selection.lua";
  };
in
{
  programs.mpv.scripts = [ script ];
}

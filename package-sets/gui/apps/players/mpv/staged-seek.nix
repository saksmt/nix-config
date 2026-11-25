{ lib, pkgs, ... }:
let
  script = pkgs.stdenv.mkDerivation {
    name = "mpv-staged-seek";
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/share/mpv/scripts
      cp ${./staged-seek.lua} $out/share/mpv/scripts/staged-seek.lua
    '';

    passthru.scriptName = "staged-seek.lua";
  };
in
{
  programs.mpv.scripts = [ script ];
}

{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

{ imports = [ (whenWork {
#    environment.systemPackages = [ pkgs.sqldeveloper ];
}) ]; }

{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

{ imports = [(whenWorkLike {
    environment.systemPackages = [ pkgs.openconnect ];
}) (whenWork {
    environment.systemPackages = [ pkgs.davmail ];
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplip ];
}) ]; }

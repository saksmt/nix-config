{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

(whenWorkLike {
    environment.systemPackages = [ pkgs.openconnect ];
}) // (whenWork {
    environment.systemPackages = [ pkgs.davmail ];
})

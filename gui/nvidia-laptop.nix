{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

when ["nVidia" "laptop"] {
    hardware.nvidia.optimus_prime.enable = true;
}

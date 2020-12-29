{ when, ... } : _:

when ["nVidia" "laptop"] {
    hardware.nvidia.optimus_prime.enable = true;
}

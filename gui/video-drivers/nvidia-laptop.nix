{ when, ... } : _:

when ["nVidia" "laptop"] {
    hardware.nvidia.modesetting.enable = true;

    imports = [
        (when ["nVidia-prime-sync"] {
             hardware.nvidia.prime.sync.enable = true;
         })

         (when ["nVidia-prime-offload"] {
            hardware.nvidia.prime.offload.enable = true;
            environment.systemPackages = [
                (pkgs.writeShellScriptBin "nvidia-offload" ''
                    export __NV_PRIME_RENDER_OFFLOAD=1
                    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
                    export __GLX_VENDOR_LIBRARY_NAME=nvidia
                    export __VK_LAYER_NV_optimus=NVIDIA_only
                    exec "$@"
                  '')
            ];
         })
    ];
}

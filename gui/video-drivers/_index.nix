{ includeAll, ... }: _: {
    imports = includeAll [
        ./intel-gpu.nix
        ./nvidia.nix
        ./nvidia-laptop.nix
    ];
}

{ includeAll, ... }: _: {
    imports = includeAll [
        ./system-setup.nix
        ./boot.nix
        ./sound.nix
        ./user-choices.nix
        ./base-packages.nix
        ./bluetooth.nix
        ./file-shares.nix
    ];
}
{ includeAll, ... }: _: {
    imports = includeAll [
        ./video-drivers/_index.nix
        ./x-setup/_index.nix
        ./window-manager/_index.nix
        ./apps/_index.nix

        ./themes.nix
    ];
}

{ includeAll, ... }: _: {
    imports = includeAll [
        ./media.nix
        ./vpn.nix
        ./work.nix
        ./gaming.nix
        ./server/_index.nix
    ];
}
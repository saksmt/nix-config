{ includeAll, ... }: _: {
    imports = includeAll [
        ./base.nix
        ./media.nix
        ./im.nix
        ./office.nix
        ./guitar.nix
        ./gaming.nix
    ];
}

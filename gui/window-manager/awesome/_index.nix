{ includeAll, ... }: _: {
    imports = includeAll [
        ./awesome-base.nix
        ./packages.nix
    ];
}
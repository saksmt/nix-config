{ includeAll, ... }: _: {
    imports = includeAll [
        ./common.nix
        ./jvm.nix
        ./kuber.nix
        ./haskell.nix
        ./rust.nix
        ./c.nix
        ./android.nix
        ./oracle.nix
        ./vm.nix
    ];
}

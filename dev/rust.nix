{ whenDev, ... } : { config, pkgs, ... }:

whenDev {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [ 
    rustc
    cargo
    jetbrains.clion
  ];
}

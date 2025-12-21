let
  nixpkgs-dependent-input = url: {
    inherit url;
    inputs.nixpkgs.follows = "nixpkgs";
  };
  use-relative-paths = true;
  in-this-repo = if (use-relative-paths) then "path:./" else "github:saksmt/nix-confg?dir=";
  nixpkgs-version = "25.11";
in
{
  nixpkgs.url = "github:nixos/nixpkgs/nixos-${nixpkgs-version}";
  nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  nixpkgs-master.url = "github:nixos/nixpkgs/master";
  nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  nixgl = nixpkgs-dependent-input "github:nix-community/nixGL";

  home-manager = nixpkgs-dependent-input "github:nix-community/home-manager/release-${nixpkgs-version}";

  # waiting for catppuccin to make a branch for nixpkgs
  #catppuccin = nixpkgs-dependent-input "github:catppuccin/nix/release-${nixpkgs-version}";
  # temprary solution - master
  catppuccin = {
    url = "github:catppuccin/nix/main";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  utils.url = "github:numtide/flake-utils";

  nix-features = nixpkgs-dependent-input "github:saksmt/nix-features";
  nix-unstables = nixpkgs-dependent-input "github:saksmt/nix-unstables";
}

let
  nixpkgs-dependent-input = url: {
    inherit url;
    inputs.nixpkgs.follows = "nixpkgs";
  };
  use-relative-paths = true;
  in-this-repo = if (use-relative-paths) then "path:./" else "github:saksmt/nix-confg?dir=";
  nixpkgs-version = "24.11";
in
{
  nixpkgs.url = "github:nixos/nixpkgs/nixos-${nixpkgs-version}";
  nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  nixgl = nixpkgs-dependent-input "github:nix-community/nixGL";

  home-manager = nixpkgs-dependent-input "github:nix-community/home-manager/release-${nixpkgs-version}";

  utils.url = "github:numtide/flake-utils";

  nix-features = nixpkgs-dependent-input "github:saksmt/nix-features";
  nix-unstables = nixpkgs-dependent-input "github:saksmt/nix-unstables";
}

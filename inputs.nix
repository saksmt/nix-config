let
  nixpkgs-dependent-input = url: {
    inherit url;
    inputs.nixpkgs.follows = "nixpkgs";
  };
  use-relative-paths = true;
  in-this-repo = if (use-relative-paths) then "path:./" else "github:saksmt/nix-confg?dir=";
in
{
  nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  nixgl = nixpkgs-dependent-input "github:nix-community/nixGL";

  home-manager = nixpkgs-dependent-input "github:nix-community/home-manager/release-24.11";

  utils.url = "github:numtide/flake-utils";

  nix-features = nixpkgs-dependent-input "${in-this-repo}shared-lib/nix-features";
  nix-unstables = nixpkgs-dependent-input "${in-this-repo}shared-lib/nix-unstables";
  nix-hm-adapter.url = "${in-this-repo}shared-lib/nix-hm-adapter";
}

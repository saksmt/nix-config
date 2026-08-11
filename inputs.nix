let
  nixpkgs-dependent-input = url: {
    inherit url;
    inputs.nixpkgs.follows = "nixpkgs";
  };
  use-relative-paths = true;
  in-this-repo = if (use-relative-paths) then "path:./" else "github:saksmt/nix-confg?dir=";
  nixpkgs-version = "26.05";
in
{
  nixpkgs.url = "github:nixos/nixpkgs/nixos-${nixpkgs-version}";
  nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  nixpkgs-master.url = "github:nixos/nixpkgs/master";
  nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  jail-nix.url = "sourcehut:~alexdavid/jail.nix";

  nix-index-database = nixpkgs-dependent-input "github:nix-community/nix-index-database";

  nixgl = nixpkgs-dependent-input "github:nix-community/nixGL";
  awesome-iwm = nixpkgs-dependent-input "github:saksmt/awesomewm-iwm";

  home-manager = nixpkgs-dependent-input "github:nix-community/home-manager/release-${nixpkgs-version}";

  catppuccin = nixpkgs-dependent-input "github:catppuccin/nix/release-${nixpkgs-version}";

  utils.url = "github:numtide/flake-utils";

  nix-features = nixpkgs-dependent-input "github:saksmt/nix-features";
  nix-unstables = nixpkgs-dependent-input "github:saksmt/nix-unstables";
}

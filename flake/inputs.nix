let
  nixpkgs-version = "26.05";
  onMac = builtins.getEnv "OS" == "Darwin";
  nixpkgs-branch = if onMac then "nixpkgs-${nixpkgs-version}-darwin" else "nixos-${nixpkgs-version}";
  nixpkgs-dependent-input = url: {
    inherit url;
    inputs.nixpkgs.follows = "nixpkgs";
  };
in
{
  nixpkgs.url = "github:nixos/nixpkgs/${nixpkgs-branch}";
  nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  nixpkgs-master.url = "github:nixos/nixpkgs/master";
  nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  jail-nix.url = "sourcehut:~alexdavid/jail.nix";
  nix-index-database = nixpkgs-dependent-input "github:nix-community/nix-index-database";

  nixgl = nixpkgs-dependent-input "github:nix-community/nixGL";
  awesome-iwm = nixpkgs-dependent-input "github:saksmt/awesomewm-iwm";

  home-manager = nixpkgs-dependent-input "github:nix-community/home-manager/release-${nixpkgs-version}";
  nix-darwin = nixpkgs-dependent-input "github:nix-darwin/nix-darwin/nix-darwin-${nixpkgs-version}";

  # 26.06 does not have darwin module
  catppuccin = nixpkgs-dependent-input "github:catppuccin/nix/${
    if onMac then "main" else "release-${nixpkgs-version}"
  }";

  utils.url = "github:numtide/flake-utils";

  nix-features = nixpkgs-dependent-input "github:saksmt/nix-features";
  nix-unstables = nixpkgs-dependent-input "github:saksmt/nix-unstables";
}

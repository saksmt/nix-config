{
  inputs =
    # region USE ./gen-inputs AND PASTE OUTPUT HERE!
    {
      home-manager = {
        inputs = {
          nixpkgs = {
            follows = "nixpkgs";
          };
        };
        url = "github:nix-community/home-manager/release-24.05";
      };
      nix-features = {
        inputs = {
          nixpkgs = {
            follows = "nixpkgs";
          };
        };
        url = "path:./shared-lib/nix-features";
      };
      nix-hm-adapter = {
        url = "path:./shared-lib/nix-hm-adapter";
      };
      nix-unstables = {
        inputs = {
          nixpkgs = {
            follows = "nixpkgs";
          };
        };
        url = "path:./shared-lib/nix-unstables";
      };
      nixos-hardware = {
        url = "github:NixOS/nixos-hardware/master";
      };
      nixpkgs = {
        url = "github:nixos/nixpkgs/nixos-24.05";
      };
      nixpkgs-unstable = {
        url = "github:nixos/nixpkgs/nixos-unstable";
      };
      utils = {
        url = "github:numtide/flake-utils";
      };
    }
  # endregion
  ;

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      utils,
      nix-features,
      nix-unstables,
      nix-hm-adapter,
      ...
    }@inputs:
    let
      installation-module-lib = import (self.outPath + "/installation-modules/lib.nix");
      nixosFromInstallationModules =
        installationPath:
        let
          inherit (installation-module-lib) includeAllRelative apply;
          installation = import (self.outPath + installationPath);
          installationModules = includeAllRelative self [ "/installation-modules/nixos" ];
          applied = apply inputs installationModules installation;
        in
        nixpkgs.lib.nixosSystem {
          modules = applied.modules;
          specialArgs = applied.module-args;
        };
      outputs = {

        repl = {
          inherit inputs;
          inherit outputs;
          inherit self;
        } // builtins // nixpkgs.lib;

        nixosConfigurations = {
          smt-laptop = nixosFromInstallationModules "/hosts/laptop.nix";

          test = nixpkgs.lib.nixosSystem {
            modules =
              (nixpkgs.lib.optional (builtins.pathExists /etc/nixos/local-hacks.nix) /etc/nixos/local-hacks.nix)
              ++ [
                (_: { nixpkgs.hostPlatform = "x86_64-linux"; })
                (import ./sys.nix)
                (import ./tst.nix)
                nix-features.nixosModules.default
                nix-hm-adapter.nixosModules.default
              ];
          };
        };

        packages =
          (utils.lib.eachDefaultSystem (
            system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            {
              packages = import ./custom-packages pkgs;
            }
          )).packages;
      };
    in
    outputs;
}

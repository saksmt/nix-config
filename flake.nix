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
        url = "github:nix-community/home-manager/release-24.11";
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
      nixgl = {
        inputs = {
          nixpkgs = {
            follows = "nixpkgs";
          };
        };
        url = "github:nix-community/nixGL";
      };
      nixos-hardware = {
        url = "github:NixOS/nixos-hardware/master";
      };
      nixpkgs = {
        url = "github:nixos/nixpkgs/nixos-24.11";
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
      home-manager,
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
      hmFromInstallationModules =
        installationPath:
        let
          inherit (installation-module-lib) includeAllRelative apply;
          installation = import (self.outPath + installationPath);
          installationModules = includeAllRelative self [ "/installation-modules/hm/standalone.nix" ];
          applied = apply inputs installationModules installation;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = applied.modules;
          extraSpecialArgs = applied.module-args;
        };
      outputs = {

        templates = {
          rust-base = {
            path = ./templates/rust-base;
            description = "Base rust template (flake, toolchain, empty rustfmt)";
          };
        };

        repl = {
          inherit inputs;
          inherit outputs;
          inherit self;
        } // builtins // nixpkgs.lib;

        nixosConfigurations = {
          smt-laptop = nixosFromInstallationModules "/hosts/laptop.nix";
        };

        homeConfigurations = {
          work-laptop = hmFromInstallationModules "/hosts/no-host/work-laptop.hm.nix";
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

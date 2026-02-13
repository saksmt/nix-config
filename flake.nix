rec {
  inputs =
    # region USE ./gen-inputs AND PASTE OUTPUT HERE!
    {
      awesome-iwm = {
        inputs = {
          nixpkgs = {
            follows = "nixpkgs";
          };
        };
        url = "github:saksmt/awesomewm-iwm";
      };
      catppuccin = {
        inputs = {
          nixpkgs = {
            follows = "nixpkgs";
          };
        };
        url = "github:catppuccin/nix/release-25.11";
      };
      home-manager = {
        inputs = {
          nixpkgs = {
            follows = "nixpkgs";
          };
        };
        url = "github:nix-community/home-manager/release-25.11";
      };
      nix-features = {
        inputs = {
          nixpkgs = {
            follows = "nixpkgs";
          };
        };
        url = "github:saksmt/nix-features";
      };
      nix-unstables = {
        inputs = {
          nixpkgs = {
            follows = "nixpkgs";
          };
        };
        url = "github:saksmt/nix-unstables";
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
        url = "github:nixos/nixpkgs/nixos-25.11";
      };
      nixpkgs-master = {
        url = "github:nixos/nixpkgs/master";
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
      nixpkgs-master,
      utils,
      nix-features,
      nix-unstables,
      ...
    }@resolvedInputs:
    let
      sourceInputs = inputs;
      installation-module-lib = import (self.outPath + "/installation-modules/lib.nix");
      installationModulesArgs = resolvedInputs // {
        nix-hm-adapter = import ./lib/nix-hm-adapter;
      };
      recipe-loader = installation-module-lib.loader {
        self = self;
        module-args = installationModulesArgs;
      };
      nixosFromInstallationModules =
        path:
        (recipe-loader.load-and-process {
          modules = [ "/installation-modules/nixos" ];
          recipe-path = path;
        }).as-nixos;
      isoFromInstallationModulesFor =
        system: path:
        (recipe-loader.load-and-process {
          modules = [ "/installation-modules/iso" ];
          recipe-path = path;
        }).as-iso
          system;
      hmFromInstallationModules =
        path:
        (recipe-loader.load-and-process {
          modules = [ "/installation-modules/hm/standalone.nix" ];
          recipe-path = path;
        }).as-hm
          "x86_64-linux";

      versionedInputs = builtins.mapAttrs (
        k: v: v // (if k == "self" then { } else { source = sourceInputs.${k}; })
      ) resolvedInputs;
      outputs = rec {

        templates = {
          rust-base = {
            path = ./templates/rust-base;
            description = "Base rust template (flake, toolchain, empty rustfmt)";
          };
        };

        repl = {
          inputs = versionedInputs;
          inherit outputs;
          inherit self;
          inherit sourceInputs;
          inputVersions = builtins.mapAttrs (
            k: v:
            let
              source = if builtins.isString v.source.url then builtins.parseFlakeRef v.source.url else v.source;
            in
            {
              name = k;
              branch =
                if source ? "ref" then
                  source.ref
                else if
                  builtins.elem source.type [
                    "git"
                    "github"
                    "gitlab"
                  ]
                then
                  "<default-branch>"
                else
                  null;
              commit = v.shortRev;
              updatedAt = v.lastModified;
            }
          ) (builtins.removeAttrs versionedInputs [ "self" ]);
        }
        // builtins
        // nixpkgs.lib;

        nixosConfigurations = {
          smt-laptop = nixosFromInstallationModules "/hosts/laptop.nix";
        };

        homeConfigurations = {
          work-laptop = hmFromInstallationModules "/hosts/no-host/work-laptop.hm.nix";
          deck = hmFromInstallationModules "/hosts/no-host/deck.hm.nix";
        };

        isoConfigurations =
          (utils.lib.eachDefaultSystem (
            system:
            let
              mkIso = isoFromInstallationModulesFor system;
            in
            {
              isos = {

                full-fat = mkIso "/hosts/iso/full-fat.nix";
                minimal-nox = mkIso "/hosts/iso/minimal-nox.nix";

              };
            }
          )).isos;

        packages =
          (utils.lib.eachDefaultSystem (
            system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            {
              packages = import ./custom-packages pkgs // {
                images = builtins.mapAttrs (_: v: v.image.iso) isoConfigurations.${system};
              };
            }
          )).packages;
      };
    in
    outputs;
}

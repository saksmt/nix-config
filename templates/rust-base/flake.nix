{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      naersk,
      rust-overlay,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [
          rust-overlay.overlays.default
          toolchainOverlay
        ];
        toolchainOverlay = final: prev: {
          rustToolchain =
            let
              rust = prev.rust-bin;
            in
            if builtins.pathExists ./rust-toolchain.toml then
              rust.fromRustupToolchainFile ./rust-toolchain.toml
            else if builtins.pathExists ./rust-toolchain then
              rust.fromRustupToolchainFile ./rust-toolchain
            else
              rust.stable.latest.default.override {
                extensions = [
                  "rust-src"
                  "rustfmt"
                ];
              };
        };
        pkgs = import nixpkgs { inherit system overlays; };
        buildDeps = with pkgs; [
          rustToolchain
          rust-analyzer
        ];
        runtimeDeps = [ ];

        naersk' =
          with pkgs;
          callPackage naersk {
            cargo = rustToolchain;
            rustc = rustToolchain;
          };
      in
      {
        defaultPackage = naersk'.buildPackage {
          src = ./.;
          buildInputs = runtimeDeps;
        };
        devShell =
          with pkgs;
          mkShell {

            buildInputs = buildDeps ++ runtimeDeps;

            shellHook = ''
              mkdir -p .pkgs &>/dev/null
              # only copy rust package if flake.lock changes since last copy
              test -f .pkgs/flake.lock && cmp -s flake.lock .pkgs/flake.lock || rsync \
                      --recursive \
                      --delete \
                      --times \
                      --atimes \
                      --copy-links \
                      --perms \
                      --chmod=ugo=rwX \
                      $(rustc --print sysroot)/ \
                      .pkgs/rustc
              cp -f flake.lock .pkgs/ &>/dev/null

              rustCoreSrcLibRs="$(find .pkgs/rustc -type f -path '*/core/src/lib.rs')"

              export RUST_SRC_ROOT_DIR="$(dirname "$(dirname "$(dirname "''${rustCoreSrcLibRs}")")")"
              export RUST_BIN_DIR=".pkgs/rustc/bin"

              printRustPaths() {
                  local dim="$(echo -en "\033")[2m"
                  local bright="$(echo -en "\033")[1m"
                  local clr="$(echo -en "\033")[0m"

                  local rustSrcAbsolutePath=$(readlink -m "''${RUST_SRC_ROOT_DIR}")
                  local borderPart="''${rustSrcAbsolutePath//?/'─'}"
                  local border="────────────────────────────────────────────────────''${borderPart}"

                  local pathSizeDiff="''${RUST_SRC_ROOT_DIR:''${#RUST_BIN_DIR}}"
                  local binBorderSpacing='              '"''${pathSizeDiff//?/' '}"

                  echo ""
                  echo "''${dim}╭''${border}╮''${clr}"
                  echo "''${dim}│''${clr} rust bin directory (''${bright}\$RUST_BIN_DIR''${clr}): ''${bright}$(readlink -m "''${RUST_BIN_DIR}")''${clr} ''${binBorderSpacing}''${dim}│''${clr}"
                  echo "''${dim}│''${clr} rust sources root directory (''${bright}\$RUST_SRC_ROOT_DIR''${clr}): ''${bright}''${rustSrcAbsolutePath}''${clr} ''${dim}│''${clr}"
                  echo "''${dim}╰''${border}╯''${clr}"
                  echo ""

                  # motivation - rsync updates create times (to not do that root priveleges are required)
                  # which leads to re-index in IDEA, so we try to only copy package if actuall changes happen
                  echo "''${bright}!!! To force update local bin & source directories from actual nixpkgs delete .pkgs (rm -rf .pkgs) !!!''${clr}"
              }

              printRustPaths
            '';
          };
      }
    );
}

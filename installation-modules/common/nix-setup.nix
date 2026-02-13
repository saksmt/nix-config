{ self, ... }@inputs:
{
  process-recipe = _: {
    modules = [
      (
        { lib, ... }:
        let
          flakeInputs =
            (lib.filterAttrs (_: lib.isType "flake") (builtins.removeAttrs inputs [ "self" ]))
            // {
              built-os = self;
              built-hm = self;
            };
        in
        {
          nix = {
            # Add each flake input as a registry and nix_path
            registry = (lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs);
            nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
          };
        }
      )
      (
        { lib, ... }:
        {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnfreePredicate = _: true;

          nix.settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            trusted-users = [
              "root"
              "smt"
              "@wheel"
            ];

            # quality-of-life, also overrides defaults with same values to
            # make it more external change proof
            log-lines = lib.mkDefault 100;
            max-build-log-size = lib.mkDefault 0;
            keep-build-log = lib.mkDefault true;
            allow-dirty = lib.mkDefault true;
            keep-derivations = lib.mkDefault true;
            # debatable, but useful for debugging
            keep-failed = lib.mkDefault true;
            # motivation: it's better to build single package with
            # parallelism than to build multiple packages in parallel
            # with single thread per package. small packages are not
            # parallelizing in any way and most likely are I/O bound,
            # big packages on the other hand support parallelized build
            # themselves so that they can be built quicker
            max-jobs = lib.mkDefault 1;
            # security is the priority =_=
            require-sigs = lib.mkForce true;
            sandbox = lib.mkForce true;
            # need to test this properly, false for now; requires "cgroups" feature
            use-cgroups = lib.mkForce false;
            # useless and makes any call to any nix command retrieve json from github
            # also related - https://github.com/NixOS/nix/issues/8953#issuecomment-1728592073
            flake-registry = "";
          };

          nix.gc = {
            automatic = lib.mkDefault true;
            dates = lib.mkDefault "weekly";
            options = lib.mkDefault "--delete-older-than 60d";
          };
        }
      )
    ];
  };
}

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
            settings.experimental-features = [
              "nix-command"
              "flakes"
            ];

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

          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];

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

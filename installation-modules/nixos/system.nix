{ nixpkgs, ... }:
{
  process-recipe = _: {
    modules = builtins.concatLists [
      (nixpkgs.lib.optional (builtins.pathExists /etc/nixos/local-hacks.nix) (import /etc/nixos/local-hacks.nix))
      (nixpkgs.lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix) (import /etc/nixos/hardware-configuration.nix))

      [
        (
          { pkgs, ... }:
          {
            environment.systemPackages = [ pkgs.os-rebuild ];
            nix.registry = {
              os.to = builtins.parseFlakeRef (nixpkgs.lib.strings.fileContents "/etc/nixos/flake-ref");
              tpl.to = builtins.parseFlakeRef (nixpkgs.lib.strings.fileContents "/etc/nixos/flake-ref");
            };
          }
        )
      ]
    ];
  };
}

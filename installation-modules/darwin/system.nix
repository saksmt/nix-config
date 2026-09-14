{ nixpkgs, ... }:
{
  process-recipe = _: {
    modules = builtins.concatLists [
      (nixpkgs.lib.optional (builtins.pathExists /etc/nixos/local-hacks.nix) (
        import /etc/nixos/local-hacks.nix
      ))
      (nixpkgs.lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix) (
        import /etc/nixos/hardware-configuration.nix
      ))

      (nixpkgs.lib.optional (builtins.pathExists "/etc/nix-adhoc-conf/system.nix") /etc/nix-adhoc-conf/system.nix)
      (nixpkgs.lib.optional (builtins.pathExists "/etc/nix-adhoc-conf/nixos.nix") /etc/nix-adhoc-conf/nixos.nix)

      [
        (
          { pkgs, lib, ... }:
          {
            environment.systemPackages = [ pkgs.os-rebuild ];
            nix.registry = {
              os.to = builtins.parseFlakeRef (nixpkgs.lib.strings.fileContents "/etc/nixos/flake-ref");
              tpl.to = builtins.parseFlakeRef (nixpkgs.lib.strings.fileContents "/etc/nixos/flake-ref");
            };
            # this is to make determinate-nix work, will need to look for a workaround
            nix.enable = lib.mkForce false;
            nix.gc.automatic = lib.mkForce false;
          }
        )
      ]
    ];
  };
}

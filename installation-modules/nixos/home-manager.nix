{ home-manager, self, ... }@inputs:
{
  process-recipe =
    {
      installation ? { },
      ...
    }:
    let
      hm-conf = installation.home-manager or { };
    in
    {
      modules =
        if hm-conf.enabled or false then
          with (import (self.outPath + "/installation-modules/lib.nix"));
          let
            hmModules = includeAllRelative self [
              "/installation-modules/common/features.nix"
              "/installation-modules/common/overlays.nix"
              "/installation-modules/common/package-sets.nix"
              "/installation-modules/common/passthrou-nixos.nix"

              "/installation-modules/hm/hm-adapter.nix"
              "/installation-modules/hm/hm-setup.nix"
            ];
            hmInstallation = hm-conf.installation or (_: { });
            applied = apply inputs hmModules (
              let
                installationF = if builtins.isAttrs hmInstallation then (_: hmInstallation) else hmInstallation;
              in
              args: {
                installation = (installationF args) // {
                  THATS_HM = true;
                };
              }
            );
          in
          [
            home-manager.nixosModules.home-manager
            (_: {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = applied.module-args;
              home-manager.sharedModules = applied.modules;
              home-manager.backupFileExtension = ".hm-backup~";
            })
          ]
        else
          [ ];
    };
}

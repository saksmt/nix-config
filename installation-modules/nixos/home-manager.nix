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
      module-args = {
        home-manager-enabled = hm-conf.enabled or hm-conf.enable or false;
      };
      modules =
        if hm-conf.enabled or hm-conf.enable or false then
          with (import (self.outPath + "/installation-modules/lib.nix"));
          let
            hmModules = includeAllRelative self [
              "/installation-modules/common/features.nix"
              "/installation-modules/common/jail-nix.nix"
              "/installation-modules/common/overlays.nix"
              "/installation-modules/common/package-sets.nix"

              "/installation-modules/hm/hm-adapter.nix"
              "/installation-modules/hm/hm-setup.nix"
              "/installation-modules/common/passthrou-nixos.nix"
              "/installation-modules/hm/external-modules.nix"
            ];
            hmInstallation = hm-conf.installation or (_: { });
            baseHmConf = builtins.removeAttrs hm-conf [
              "installation"
              "enable"
              "enabled"
            ];
            applied = apply inputs hmModules (
              let
                installationF = if builtins.isAttrs hmInstallation then (_: hmInstallation) else hmInstallation;
              in
              args:
              {
                installation = (installationF args);
              }
              // baseHmConf
            );
          in
          [
            home-manager.nixosModules.home-manager
            (
              { config, ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = applied.module-args // {
                  host-config = config;
                };
                home-manager.sharedModules = applied.modules;
                home-manager.backupFileExtension = ".hm-backup~";
              }
            )
          ]
        else
          [ ];
    };
}

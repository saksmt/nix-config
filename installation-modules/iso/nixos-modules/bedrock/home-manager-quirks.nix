{ config, lib, ... }:
let
  getDrvPath = pkg: pkg.drvPath;
  optNull = x: if x == null then [ ] else [ x ];
  users = (config.home-manager or { }).users or { };
  userNames = builtins.attrNames users;
  activationPackagesFor =
    user:
    let
      pkg = optNull ((user.home or { }).activationPackage or null);
      drvPathOfPkg = getDrvPath pkg;
    in
    pkg ++ (lib.optionals config.images.iso.include-system-build-dependencies drvPathOfPkg);
  activationPackages = builtins.concatMap activationPackagesFor userNames;
in
{
  config.home-manager.sharedModules = [
    {
      # home-manager activation fails on startup when there is no internet connection
      # due to a call to nix-store --realise which for some reason doesn't work
      # without attempting to fetch cache
      # see https://github.com/nix-community/home-manager/issues/6638
      home.activationGenerateGcRoot = config.images.iso.include-system-build-dependencies;
    }
  ];
  config.images.iso.nix-store-contents = activationPackages;
  config.nix.settings.fallback = true;

  config.system.activationScripts = {
    base-dirs =
      let
        createPerUserDir = builtins.map (
          user: "mkdir -p /nix/var/nix/profiles/per-user/${user} || true"
        ) userNames;
        script = builtins.concatStringsSep "\n" createPerUserDir;
      in
      {
        text = script;
        deps = [ ];
      };
  };
}

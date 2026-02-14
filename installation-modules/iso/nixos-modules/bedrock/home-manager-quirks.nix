{ config, lib, home-manager-enabled, ... }:
let
  getDrvPath = pkg: pkg.drvPath;
  optNull = x: if x == null then [ ] else [ x ];
  users = (config.home-manager or { }).users or { };
  isEmpty = builtins.all (_: false);
  userNames = builtins.attrNames users;
  hm-enabled = isEmpty userNames;
  activationPackagesFor =
    user:
    let
      pkg = optNull ((user.home or { }).activationPackage or null);
      drvPathOfPkg = getDrvPath pkg;
    in
    pkg ++ (lib.optionals config.images.iso.include-system-build-dependencies drvPathOfPkg);
  activationPackages = builtins.concatMap activationPackagesFor userNames;
in
(
  if home-manager-enabled then
    {
      config.home-manager.sharedModules = lib.mkIf hm-enabled [
        {
          # home-manager activation fails on startup when there is no internet connection
          # due to a call to nix-store --realise which for some reason doesn't work
          # without attempting to fetch cache
          # see https://github.com/nix-community/home-manager/issues/6638
          home.activationGenerateGcRoot = config.images.iso.include-system-build-dependencies;
        }
      ];
    }
  else
    { }
)
// {
  config = lib.mkIf hm-enabled {
    nix.settings.fallback = true;
    images.iso.nix-store-contents = lib.mkIf hm-enabled activationPackages;

    system.activationScripts = lib.mkIf hm-enabled {
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
  };
}

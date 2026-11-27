{
  pkgs,
  config,
  ...
}:
{
  module-for = [ "nixos" ];
  # autologin and autolaunch of steam
  services.displayManager = {
    sddm.autoLogin.relogin = false;

    autoLogin = {
      enable = true;
      user = config.environment.couch-potato.user.name;
    };
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "steamos-session-select" "steam -shutdown")
  ];
}

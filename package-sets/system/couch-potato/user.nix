{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.environment.couch-potato.user;
in
{
  options.environment.couch-potato.user = {
    name = lib.mkOption {
      description = "name of couch potato user, if you ever want to override iconic \"potato\"";
      type = lib.types.str;
      default = "potato";
    };
    create = lib.mkOption {
      description = "whether to create \${environment.couch-potato.user.name}";
      type = lib.types.bool;
      default = true;
    };
  };

  config.users.users = lib.mkIf cfg.create {
    ${cfg.name} = {
      description = "The Couch Potato";
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "video"
        "render"
        "audio"
        "input"
      ];
      initialHashedPassword = "";
    };
  };
  # Polkit power management rules
  config.security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user == "${cfg.name}" &&
          (action.id == "org.freedesktop.login1.power-off" ||
           action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
           action.id == "org.freedesktop.login1.reboot" ||
           action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
           action.id == "org.freedesktop.login1.suspend" ||
           action.id == "org.freedesktop.login1.suspend-multiple-sessions")) {
        return polkit.Result.YES;
      }
    });
  '';
}

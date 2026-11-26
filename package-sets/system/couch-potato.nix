# adds couch potato mode:
#  - potato passwordless user with autologin
#  - gamescope with steam big picture session
# ~~for extra flavor~~ don't forget to add complementary:
# - gui/apps/game-streaming - moonlight
# - gui/apps/players - mpv
# - gui/apps/steam-couch-potato-apps - couch potato steam apps config
{
  pkgs,
  lib,
  features,
  ...
}:
let
  userName = "potato";
in
{
  module-for = [ "nixos" ];
  # autologin and autolaunch of steam
  services.displayManager = {
    sddm.autoLogin.relogin = false;
    defaultSession = "steam";

    autoLogin = {
      enable = true;
      user = "potato";
    };
  };

  # exit session from steam
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "steamos-session-select" "steam -shutdown")
  ];

  # gamescope
  programs.steam.gamescopeSession = {
    enable = true;
    args = [
      /*nixfmt:disable*/
      "-O" "*,eDP-1"
      /*nixfmt:enable*/
      "--adaptive-sync"
      "--hdr-enabled"
      "--hdr-debug-force-output"
      "--expose-wayland"
      "--rt"
    ];
    steamArgs = [
      "-tenfoot"
      "-pipewire-dmabuf"
      "-steamos3"
    ];
    env = {
      ENABLE_GAMESCOPE_WSI = "1";
    };
  };

  # user
  users.users.${userName} = {
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
  # Polkit power management rules
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user == "${userName}" &&
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
// (
  if features.guitar.isEnabled then
    {
      # realtime audio for rocksmith

      security.rtkit.enable = true;
      security.pam.loginLimits = [
        {
          domain = "@audio";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "@audio";
          item = "rtprio";
          type = "-";
          value = "99";
        }
        {
          domain = "@audio";
          item = "nice";
          type = "-";
          value = "-19";
        }
      ];

      services.pipewire.extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.min-quantum" = 64;
          "default.clock.max-quantum" = 1024;
        };
      };

      programs.steam.package = pkgs.steam.override {
        extraPkgs = pkgs': [
          pkgs'.wineasio
          pkgs'.pipewire.jack
        ];
        extraLibraries = pkgs': [
          pkgs'.wineasio
          pkgs'.pipewire.jack
        ];
      };
    }
  else
    { }
)

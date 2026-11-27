# adds couch potato mode:
#  - potato passwordless user with autologin
#  - gamescope/hyprland with steam big picture session
# ~~for extra flavor~~ don't forget to add complementary:
# - gui/apps/game-streaming - moonlight
# - gui/apps/players - mpv
# - gui/apps/steam-couch-potato-apps - couch potato steam apps config
{
  module-for = [ "nixos" ];
  imports = [
    # (import ./gamescope-impl)
    (import ./hyprland-impl)
    (import ./user.nix)
    (import ./module.nix)
    (import ./guitar.nix)
    (import ./sddm.nix)
  ];
}

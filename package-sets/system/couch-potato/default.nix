# adds couch potato mode:
#  - potato passwordless user with autologin
#  - gamescope with steam big picture session
# ~~for extra flavor~~ don't forget to add complementary:
# - gui/apps/game-streaming - moonlight
# - gui/apps/players - mpv
# - gui/apps/steam-couch-potato-apps - couch potato steam apps config
{
  module-for = [ "nixos" ];
  imports = [
    (import ./gamescope.nix)
    (import ./user.nix)
    (import ./output-auto-switch.nix)
    (import ./guitar.nix)
    (import ./sddm.nix)
  ];
}

uses: { config, pkgs, ... }:
with uses;

whenHomeLike {
    fileSystems."/mnt/nfs" = {
        device = "home-server:/data";
        fsType = "nfs";
        options = [ "defaults" "noauto" "nofail" "user" "x-systemd.automount" ];
    };
}

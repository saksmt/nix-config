uses: { config, pkgs, ... }:
with uses;

whenHomeLike {
    fileSystems."/mnt/nfs" = {
        device = "192.168.31.31:/data";
        fsType = "nfs";
        options = [ "defaults" "noauto" "nofail" "user" "x-systemd.automount" ];
    };
}

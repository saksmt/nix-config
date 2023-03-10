uses: { config, pkgs, ... }:
with uses;

whenHomeLike {
    # todo: nfs? samba? sshfs? need something portable, fast and with attrs
    #fileSystems."/mnt/nfs" = {
    #    device = "home-server:/data";
    #    fsType = "nfs";
    #    options = [ "defaults" "noauto" "nofail" "user" "x-systemd.automount" ];
    #};
}

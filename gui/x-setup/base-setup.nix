{ whenNotNoX, whenLaptop, ... } : { pkgs, ... }:

whenNotNoX { imports = [{

    environment.systemPackages = [ pkgs.xsel pkgs.dconf ];

    services.xserver.enable = true;
    services.gnome.gnome-keyring.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    programs.dconf.enable = true;

} (whenLaptop {
    services.xserver.libinput.enable = true;
    services.xserver.libinput.touchpad.disableWhileTyping = true;
})]; }

{ whenNotNoX, whenLaptop, ... } : { pkgs, ... }:

whenNotNoX { imports = [{

    environment.systemPackages = [ pkgs.xsel pkgs.gnome3.dconf ];

    services.xserver.enable = true;
    services.gnome3.gnome-keyring.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    environment.variables.GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];

    programs.dconf.enable = true;

} (whenLaptop {
    services.xserver.libinput.enable = true;
    services.xserver.libinput.disableWhileTyping = true;
    services.xserver.multitouch.enable = true;
    services.xserver.multitouch.ignorePalm = true;
})]; }

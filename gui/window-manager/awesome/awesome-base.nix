{ whenNotNoX, ... } : { pkgs, ... }:

whenNotNoX {
    environment.systemPackages = [ pkgs.lua ];

    services.xserver.windowManager.awesome.enable = true;
    services.xserver.windowManager.awesome.package = pkgs.awesome;

    services.xserver.displayManager.sddm.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;
    security.pam.services.sddm.startSession = true;

    programs.gnupg.agent.pinentryFlavor = "curses";
}

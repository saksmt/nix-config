{ whenNotNoX, ... } : { pkgs, ... }:

whenNotNoX {
    environment.systemPackages = with pkgs; [
        vanilla-dmz
        numix-gtk-theme        
        numix-icon-theme-square
        paper-icon-theme
    ];
}

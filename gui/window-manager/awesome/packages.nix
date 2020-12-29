{ whenNotNoX, ... }: { pkgs, ... }:

whenNotNoX {
    environment.systemPackages = with pkgs; [
        scrot
        feh
        lxappearance
        pavucontrol
    ];
}
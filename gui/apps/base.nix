{ whenNotNoX, whenHome, ... }: { pkgs, ... }:

whenNotNoX {
    environment.systemPackages = with pkgs; [
        firefox

        pcmanfm
        xarchiver
        roxterm

        rofi
        parcellite

        keepassxc
    ];

    nixpkgs.config.firefox = {
        ffmpegSupport = true;
    };

    imports = [(whenHome {
        environment.systemPackages = [ pkgs.transmission-remote-gtk ];
    })];
}

{ whenNotNoX, whenHomeLike, ... }: { pkgs, ... }:

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

    imports = [(whenHomeLike {
        environment.systemPackages = [ pkgs.transmission-remote-gtk ];
    })];
}

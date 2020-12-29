{ whenNotNoX, ... }: { pkgs, ... }:

whenNotNoX {
    environment.systemPackages = with pkgs; [

        deadbeef-with-plugins

        mpv
        smplayer

    ];

    nixpkgs.config.mpv = {
        lameSupport = true;
        theoraSupport = true;
        x264Support = true;
    };
}

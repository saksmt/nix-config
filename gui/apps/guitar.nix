{ whenGuitar, whenNotNoX, ... }: { pkgs, ... }:

whenNotNoX(whenGuitar {
    environment.systemPackages = with pkgs; [ tuxguitar timidity ];
})

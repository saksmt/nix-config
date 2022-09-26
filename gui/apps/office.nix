{ whenNotNoX, whenWorkLike, ... }: { pkgs, ... }:

whenNotNoX {
    environment.systemPackages = [ pkgs.qpdfview ];

    imports = [(whenWorkLike {
        environment.systemPackages = with pkgs; [ 
            libreoffice
        ];
    })];
}

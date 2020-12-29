{ whenNotNoX, whenWork, whenWorkLike, ... }: { pkgs, ... }: 

whenNotNoX {
    environment.systemPackages = with pkgs; [
        tdesktop
        discord
    ];

    imports = [(whenWork {
        environment.systemPackages = [ pkgs.gnome3.evolution ];
    }) (whenWorkLike {
        environment.systemPackages = [ pkgs.slack pkgs.zoom-us ];
    })];
}

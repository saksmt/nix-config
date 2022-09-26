{ whenNotNoX, whenWork, whenWorkLike, ... }: { pkgs, ... }: 

with pkgs;

whenNotNoX {
    environment.systemPackages = [
        tdesktop
        discord
    ];

    imports = [(whenWork {
        environment.systemPackages = [ gnome3.evolution ];
    }) (whenWorkLike {
        environment.systemPackages = [ slack zoom-us ];
    })];
}

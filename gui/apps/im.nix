{ whenNotNoX, whenWork, whenWorkLike, ... }: { pkgs, ... }: 

with pkgs;

whenNotNoX {
    environment.systemPackages = [
        tdesktop
        discord
    ];

    imports = [(whenWork {
        programs.evolution = {
          enable = true;
          plugins = [ pkgs.evolution-ews ];
        };
    })];
}

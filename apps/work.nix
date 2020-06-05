{ whenWork, whenWorkLike, ... } : { config, pkgs, ... }:

{ imports = [(whenWorkLike {
    environment.systemPackages = [ pkgs.openconnect pkgs.zoom-us ];
}) (whenWork {
    environment.systemPackages = [ pkgs.davmail ];
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplip ];
}) ]; }

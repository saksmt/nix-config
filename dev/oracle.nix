{ whenWork, ... }: { config, pkgs, ... }:

{ imports = [ (whenWork {
#    environment.systemPackages = [ pkgs.sqldeveloper ];
}) ]; }

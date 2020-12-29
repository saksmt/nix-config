{ whenMediaServer, ... }: { pkgs, ... }:

whenMediaServer {
    programs.java.enable = true;
    programs.java.package = pkgs.jdk11;
}
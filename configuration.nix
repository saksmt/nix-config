stdNix@{ config, pkgs, ... }:

let configFiles = [

  ./base-setup/_index.nix
  ./apps/_index.nix
  ./gui/_index.nix
  ./dev/_index.nix

]; in

let env = import ./env.nix;
    globalConf = removeAttrs env [ "additionalConfiguration" ];
    useFunctions = (import ./lib/uses/use-functions.nix) { conf = globalConf; } stdNix;
    globalScope = rec { 
      g = useFunctions // {
        conf = globalConf;
        include = file: (import file) g;
        includeAll = files: map g.include files;
      };
    }.g;
    include = globalScope.include;
    includeAll = globalScope.includeAll;
in {
  imports = [
    (include ./lib/overlaying.nix)
    ./hardware-configuration.nix
  ] ++ (includeAll configFiles) ++ [ env.additionalConfiguration ];
}

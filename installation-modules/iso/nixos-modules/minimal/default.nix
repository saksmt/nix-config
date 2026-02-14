# This module contains the basic configuration for building a NixOS
# installation CD.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    ./minimal-functional.nix
    ./installer.nix
  ];

  # To speed up installation a little bit, include the complete
  # stdenvNoCC in the Nix store on the CD.
  system.extraDependencies =
    with pkgs;
    [
      stdenvNoCC # for runCommand
      busybox
      # For boot.initrd.systemd
      makeInitrdNGTool
    ]
    ++ jq.all; # for closureInfo

  environment.defaultPackages = with pkgs; [
    rsync
  ];

  # todo: include channel

}

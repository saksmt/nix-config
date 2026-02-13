# This module contains the basic configuration for building a NixOS
# installation CD.
{
  config,
  lib,
  options,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    ./barebones.nix

    (modulesPath + "/profiles/base.nix")
    (modulesPath + "/profiles/installation-device.nix")
  ];

  hardware.enableAllHardware = true;

  # Adds terminus_font for people with HiDPI displays
  console.packages = options.console.packages.default ++ [ pkgs.terminus_font ];

  # Add Memtest86+ to the CD.
  images.iso.boot.grub.include-memtest = true;

  # An installation media cannot tolerate a host config defined file
  # system layout on a fresh machine, before it has been formatted.
  swapDevices = lib.mkImageMediaOverride [ ];
  fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;
  boot.initrd.luks.devices = lib.mkImageMediaOverride { };

  boot.postBootCommands = ''
    for o in $(</proc/cmdline); do
      case "$o" in
        live.nixos.passwd=*)
          set -- $(IFS==; echo $o)
          echo "nixos:$2" | ${pkgs.shadow}/bin/chpasswd
          ;;
      esac
    done
  '';

  environment.defaultPackages = with pkgs; [
    rsync
  ];

  programs.git.enable = lib.mkDefault true;

  system.stateVersion = lib.mkDefault lib.trivial.release;
}
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
    ./barebones.nix

    # Enable devices which are usually scanned, because we don't know the
    # target system.
    (modulesPath + "/installer/scan/detected.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  images.iso.boot.grub.theme =
    config.catppuccin.sources.grub
    + "/share/grub/themes/catppuccin-${config.catppuccin.flavor}-grub-theme";

  hardware.enableAllHardware = true;

  # An installation media cannot tolerate a host config defined file
  # system layout on a fresh machine, before it has been formatted.
  swapDevices = lib.mkImageMediaOverride [ ];
  fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;
  boot.initrd.luks.devices = lib.mkImageMediaOverride { };

  # Tell the Nix evaluator to garbage collect more aggressively.
  # This is desirable in memory-constrained environments that don't
  # (yet) have swap set up.
  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";

  # Make the installer more likely to succeed in low memory
  # environments.  The kernel's overcommit heustistics bite us
  # fairly often, preventing processes such as nix-worker or
  # download-using-manifests.pl from forking even if there is
  # plenty of free memory.
  boot.kernel.sysctl."vm.overcommit_memory" = "1";

  boot.swraid.enable = true;
  # remove warning about unset mail
  boot.swraid.mdadmConf = "PROGRAM ${pkgs.coreutils}/bin/true";

  # Show all debug messages from the kernel but don't log refused packets
  # because we have the firewall enabled. This makes installs from the
  # console less cumbersome if the machine has a public IP.
  networking.firewall.logRefusedConnections = lib.mkDefault false;

  # Prevent installation media from evacuating persistent storage, as their
  # var directory is not persistent and it would thus result in deletion of
  # those entries.
  environment.etc."systemd/pstore.conf".text = ''
    [PStore]
    Unlink=no
  '';

  system.stateVersion = lib.mkDefault lib.trivial.release;

  # Remove all speechd voices to save some space
  nixpkgs.overlays = [
    (_: prev: {
      mbrola-voices = prev.mbrola-voices.override {
        # remove all
        languages = [ ];
      };
    })
  ];

}

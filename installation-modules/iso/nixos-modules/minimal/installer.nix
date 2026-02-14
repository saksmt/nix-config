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

  system.nixos.variant_id = lib.mkDefault "installer";

  # Allow the user to log in as root without a password.
  users.users.root.initialHashedPassword = "";

  # Don't require sudo/root to `reboot` or `poweroff`.
  security.polkit.enable = true;

  # Include support for various filesystems and tools to create / manipulate them.
  boot.supportedFilesystems = lib.mkMerge [
    [
      "btrfs"
      "cifs"
      "f2fs"
      "ntfs"
      "vfat"
      "xfs"
    ]
    (lib.mkIf (lib.meta.availableOn pkgs.stdenv.hostPlatform config.boot.zfs.package) {
      zfs = lib.mkDefault true;
    })
  ];

  # Configure host id for ZFS to work
  networking.hostId = lib.mkDefault "8425e349";
}

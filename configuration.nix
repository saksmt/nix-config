# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./base-setup.nix
      ./user.nix
      ./dev/common.nix
      ./dev/c.nix
      ./dev/jvm.nix
      ./dev/haskell.nix
      ./gui/base.nix
      ./gui/nvidia.nix
      ./gui/apps.nix
      ./gui/awesome.nix
      ./gui/kde.nix
      ./work.nix
    ];
}

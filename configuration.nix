{ config, pkgs, ... }:

let configFiles = [

  ./base-setup.nix
  ./dev/common.nix
  ./dev/c.nix
  ./dev/kuber.nix
  ./dev/jvm.nix
  ./dev/haskell.nix
  ./dev/oracle.nix
  ./dev/vm.nix
  ./dev/android.nix
  ./dev/rust.nix
  ./apps/vpn.nix
  ./apps/work.nix
  ./apps/media.nix
  ./apps/server.nix
  ./apps/media-server.nix
  ./gui/base.nix
  ./gui/nvidia.nix
  ./gui/intel-gpu.nix
  ./gui/nvidia-laptop.nix
  ./gui/apps.nix
  ./gui/awesome.nix
  ./apps/guitar.nix
  ./apps/gaming.nix

]; in

with (import ./env.nix);

let uses = import ./lib/uses/env-functions.nix;
    include = file: (import file) uses;
    includeAll = files: map include files;
in {
  imports = [
    ((include ./lib/unstable-overlaying.nix) (import ./unstables.nix))
    ./hardware-configuration.nix
  ] ++ (includeAll configFiles) ++ [ additionalConfiguration ];
}

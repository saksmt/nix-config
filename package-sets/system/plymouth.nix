{
  config,
  lib,
  features,
  ...
}:
with features;
if GUI.isEnabled then {
  module-for = [ "nixos" ];
  boot.plymouth.enable = lib.mkDefault true;
  boot.kernelParams = lib.mkDefault [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    # "i915.fastboot=1" # alternative below
    "plymouth.use-simpledrm"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];
  boot.consoleLogLevel = lib.mkDefault 0;
  boot.initrd.verbose = lib.mkDefault false;
  catppuccin.plymouth.enable = true;
} else {}

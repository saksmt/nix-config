{
  config,
  lib,
  features,
  ...
}:
with features;
if GUI.isEnabled then {
  module-for = [ "nixos" ];
  boot.plymouth.enable = true;
  boot.kernelParams = [
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
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  catppuccin.plymouth.enable = true;
} else {}

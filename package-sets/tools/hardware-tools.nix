{
  pkgs,
  lib,
  ...
}:

{
  module-for = [
    "nixos"
    "hm"
  ];
  install.packages = with pkgs; [
    lshw
    pciutils
    hwinfo
    hdparm
    smartmontools
    nvme-cli
    gptfdisk
    parted
  ];
}

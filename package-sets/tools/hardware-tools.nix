{
  pkgs,
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
    usbutils
    hwinfo
    sdparm
    hdparm
    smartmontools
    nvme-cli
    gptfdisk
    parted
  ];
}

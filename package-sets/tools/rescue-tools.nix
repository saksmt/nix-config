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
    testdisk
    ms-sys
    efibootmgr
    efivar
    ddrescue
  ];
}

{
  features,
  lib,
  pkgs,
  ...
}:
lib.mkMerge [
  {
    module-for = [
      "hm"
      "nixos"
    ];
  }
  (features.work.whenEnabled {

    install.packages = with pkgs; [
      openconnect
      davmail
    ];
  })
]

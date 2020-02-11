{ whenDev, whenNotNoX, ... } : { config, pkgs, ... }:

whenDev(whenNotNoX {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    virtualboxWithExtpack
  ];
})

{ whenDev, whenNotNoX, ... } : { config, pkgs, ... }:

whenDev(whenNotNoX {
  nixpkgs.config.allowUnfree = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "smt" ];
})

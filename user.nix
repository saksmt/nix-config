{ config, pkgs, ... }:

{
  users.extraUsers.smt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };
}

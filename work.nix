{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ openconnect davmail slack ];
}

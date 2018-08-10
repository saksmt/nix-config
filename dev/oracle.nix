{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ 
    oracle-instantclient
    sqldeveloper
  ];
}

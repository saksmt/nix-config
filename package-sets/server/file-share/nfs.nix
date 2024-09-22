{ lib, ... }:
{
  # assuming exports config either in host/local config or in ZFS/external
  services.nfs.server.enable = true;

  services.nfs.server.lockdPort = lib.mkDefault 4001;
  services.nfs.server.mountdPort = lib.mkDefault 4002;
  services.nfs.server.statdPort = lib.mkDefault 4000;
}

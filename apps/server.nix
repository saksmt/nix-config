{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenServer {
  services.sshd.enable = true;
  services.openssh.permitRootLogin = "yes";
}
{ whenServer, ... } : { config, pkgs, ... }:

whenServer {
  services.sshd.enable = true;
  services.openssh.permitRootLogin = "yes";
}

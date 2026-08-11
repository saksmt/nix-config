{ pkgs, features, ... }:
with features;
{
  services.sshd.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PrintMotd = false;
    };
  };
}
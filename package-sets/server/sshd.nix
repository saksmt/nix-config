{ pkgs, features, ... }:
with features;
{
  services.sshd.enable = true;
  services.openssh = {
    enable = true;
    setting = {
      PrintMotd = false;
    };
  };
}
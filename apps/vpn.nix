{ config, pkgs, ... }:
with (import ../lib/env-functions.nix);

whenHome {
  services.openvpn.servers = {
    vds = { config = '' config /root/ovpn.config '';
            updateResolvConf = true;
            autoStart = false;
          };
  };
}

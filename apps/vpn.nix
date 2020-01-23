{ whenHome, ... } : { config, pkgs, ... }:

whenHome {
  services.openvpn.servers = {
    vds = { config = '' config /root/ovpn.config '';
            updateResolvConf = true;
            autoStart = false;
          };
  };
}

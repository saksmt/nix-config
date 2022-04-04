{ whenHome, ... } : { config, pkgs, ... }:

whenHome {
  services.openvpn.servers = {
    vds = { config = '' config /home/smt/.config/ovpn.conf '';
            updateResolvConf = true;
            autoStart = false;
          };
  };
}

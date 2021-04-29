{ includeAll, ... }: _: {
    imports = includeAll [
        ./sshd.nix
        ./docker.nix
        ./firewall.nix
        ./ftpd.nix
        ./file-share.nix
        ./jvm.nix
        ./media-server.nix
        ./torrents.nix
        ./samba.nix
    ];
}

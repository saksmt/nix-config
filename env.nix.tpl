{
    # "use flags"
    use = [ "pc" "home" "work-like" ];

    # by default load unstable nixpkgs from github as tarball
    unstablePath = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixpkgs-unstable.tar.gz;
    forkedPath = ../nixpkgs;

    # additional configuration specific to this deployment
    additionalConfiguration = { config, pkgs, ... }: {
        services.xserver.displayManager.sessionCommands = ''\
            ${pkgs.xorg.xrandr}/bin/xrandr --output DP-4 --auto --pos 0x840 --primary \
                                           --output DP-2 --auto --pos 1920x0 --rotate left \
                                           --output HDMI-0 --auto --pos 3000x725 \
        '';
        users.extraUsers.smt = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "docker" ];
            shell = pkgs.zsh;
        };
        networking.hostName = "HOSTNAME";
    };
}

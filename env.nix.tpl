{
    # enabled overlays
    overlays = [ "unstables" "plugins" ];

    # "use flags", note that "efi" flag is currently broken beyond repair (hardcode for my pc using grub which don't 
    #                                                                     fucking work normally with 4K even on fucking threadripper with 64Gb RAM)
    use = [ "pc" "home" "work-like" ];

    # packages that need plugins, in format: full-package-name = [ list-of-plugin-packages ]
    plugins = pkgs: {
        deadbeef-with-plugins = [ pkgs.deadbeef-mpris2-plugin ];
    };

    # assuming usage of https://github.com/saksmt/local-bin/blob/develop/bin/repin-unstable-nixpkgs which allows pinning of unstable nixpkgs
    unstablePath = import ./.unstable-nixpkgs.nix;
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

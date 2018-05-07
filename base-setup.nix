{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.useOSProber = true;

  networking.hostName = "smt-work-laptop";
  networking.networkmanager.enable = true;
  
  i18n = {
    consoleFont = "cyr-sun16";
    consoleKeyMap = "ruwin_alt_sh-UTF-8";
    defaultLocale = "ru_RU.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget htop oh-my-zsh zsh git nfs-utils
  ];

  programs.vim.defaultEditor = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  powerManagement.cpuFreqGovernor = "ondemand";

  environment.shells = [ pkgs.zsh pkgs.bashInteractive ];
  
  users.users.root.shell = pkgs.zsh;

  programs.zsh.enable = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.theme = "gentoo";
  programs.zsh.ohMyZsh.plugins = [ "git" "nix" "docker" ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

}

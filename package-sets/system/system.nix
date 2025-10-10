{
  pkgs,
  lib,
  features,
  ...
}:
with features;

{
  module-for = [ "nixos" ];

  environment.systemPackages = with pkgs; [
    nfs-utils
    exfat
    inetutils
    lm_sensors
  ];

  networking.networkmanager.enable = lib.mkDefault laptop.isEnabled;
  services.upower.enable = lib.mkDefault laptop.isEnabled;

  system.stateVersion = lib.mkDefault "24.05";

  nixpkgs.config.glibc.installLocales = true;

  console = {
    earlySetup = true;
    packages = lib.mkDefault [ pkgs.terminus_font ];
    keyMap = "ruwin_alt_sh-UTF-8";
    font = if HiDPI.isEnabled then "ter-k32n" else "ter-k16n";
  };

  i18n = {
    defaultLocale = "ru_RU.UTF-8";
  };

  time.timeZone = lib.mkDefault "Asia/Tbilisi";

  powerManagement.cpuFreqGovernor = lib.mkOverride 900 (
    if laptop.isEnabled then "ondemand" else "performance"
  );

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  security.pam.u2f = {
    enable = true;
    control = "sufficient";
    settings.cue = true;
    #    authFile = .u2f/authorized_keys; # this is broken. it requires path which disallows placement inside user HOME anywhere but default
  };

  services.pipewire = {
    enable = lib.mkDefault GUI.isEnabled;
    alsa.enable = lib.mkDefault GUI.isEnabled;
    alsa.support32Bit = true;
    pulse.enable = lib.mkDefault GUI.isEnabled;
    jack.enable = lib.mkDefault guitar.isEnabled;
  };
}

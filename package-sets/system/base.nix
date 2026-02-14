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
    ccrypt
    cryptsetup
    fuse
    fuse3
  ];

  nixpkgs.config.glibc.installLocales = true;

  console =
    let
      getFont = font: "${pkgs.terminus_font}/share/consolefonts/${font}.psf.gz";
    in
    {
      earlySetup = true;
      packages = lib.mkDefault [ pkgs.terminus_font ];
      keyMap = "ruwin_alt_sh-UTF-8";
      font = getFont (if HiDPI.isEnabled then "ter-v32n" else "ter-v16n");
    };
  catppuccin.tty.enable = true;

  i18n = {
    defaultLocale = "ru_RU.UTF-8";
  };

  time.timeZone = lib.mkDefault "Asia/Tbilisi";

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

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

  services.kmscon = {
    enable = true;
    extraConfig = lib.concatStringsSep "\n" [
      # Iosevka is too heavy to build on small machines,
      # fix this when there is a private cache available
      "font-name=Hasklig"
      "font-size=${if HiDPI.isEnabled then "24" else "16"}"

      "xkb-layout=us,ru"
      "xkb-options=grp:alt_shift_toggle"

      # todo: migrate to catppuccin official when available
      "palette=custom"

      "palette-black=73,77,100"
      "palette-red=237,135,150"
      "palette-green=166,218,149"
      "palette-yellow=238,212,159"
      "palette-blue=138,173,244"
      "palette-magenta=245,189,230"
      "palette-cyan=139,213,202"
      "palette-light-grey=184,192,224"

      "palette-dark-grey=91,96,120"
      "palette-light-red=237,135,150"
      "palette-light-green=166,218,149"
      "palette-light-yellow=238,212,159"
      "palette-light-blue=138,173,244"
      "palette-light-magenta=245,189,230"
      "palette-light-cyan=139,213,202"
      "palette-white=165,173,203"

      "palette-foreground=202,211,245"
      "palette-background=36,39,58"
    ];
  };

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

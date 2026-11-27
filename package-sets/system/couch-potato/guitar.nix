{
  lib,
  features,
  pkgs,
  ...
}:
# realtime audio for rocksmith
lib.optionalAttrs features.guitar.isEnabled {
  security.rtkit.enable = true;
  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@audio";
      item = "nice";
      type = "-";
      value = "-19";
    }
  ];

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.min-quantum" = 64;
      "default.clock.max-quantum" = 1024;
    };
  };

  programs.steam.package = pkgs.steam.override {
    extraPkgs = pkgs': [
      pkgs'.wineasio
      pkgs'.pipewire.jack
    ];
    extraLibraries = pkgs': [
      pkgs'.wineasio
      pkgs'.pipewire.jack
    ];
  };
}

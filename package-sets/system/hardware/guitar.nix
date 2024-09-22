{
  config,
  lib,
  features,
  ...
}:
lib.mkMerge [
  {
    module-for = [ "nixos" ];
  }
  (features.guitar.whenEnabled {
    # allowing for mkDefault of bluetooth package to override this
    hardware.pulseaudio.package = lib.mkOverride 1100 (
      config.hardware.pulseaudio.override {
        jackaudioSupport = true;
      }
    );

    services.jack = {
      jackd.enable = true;
      alsa.enable = false;
      loopback.enable = true;
    };

    boot.kernelModules = [
      "snd-seq"
      "snd-rawmidi"
    ];
  })
]

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
    boot.kernelModules = [
      "snd-seq"
      "snd-rawmidi"
    ];
  })
]

{ feature, self }:
{
  GUI = feature { default-enabled = true; };
  EFI = feature { default-enabled = true; };

  HiDPI = feature { };

  guitar = feature { };
  bluetooth = feature { };

  laptop = feature { includes = [ self.bluetooth ]; };

  dev = {
    all = feature {
      includes = [
        self.dev.scala
        self.dev.jvm-other
        self.dev.haskell
        self.dev.nix
        self.dev.k8s
      ];
    };

    common = feature { };

    haskell = feature { includes = [ self.dev.common ]; };
    nix = feature { includes = [ self.dev.common ]; };
    k8s = feature { includes = [ self.dev.common ]; };

    jvm = feature { includes = [ self.dev.common ]; };

    scala = feature { includes = [ self.dev.jvm ]; };
    jvm-other = feature { includes = [ self.dev.jvm ]; };
  };

  work = feature { };
  # to disable stuff banned at work
  work-ban = feature { default-enabled = false; };
  gaming = feature { };
  android = feature { };
}

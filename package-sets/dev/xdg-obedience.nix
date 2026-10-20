{
  pkgs,
  lib,
  ...
}:
let
  inCache = path: "%C/${path}";

  fromHomeSymlinkDirs = {
    ".npm" = inCache "npm";
    ".bun/install/cache" = inCache "bun";
    ".gradle" = inCache "gradle";
    ".m2" = inCache "m2";
    ".ivy2" = inCache "ivy2";
    ".sbt" = inCache "sbt";
    ".stack/snapshots" = inCache "stack-snapshots";
    ".stack/programs" = inCache "stack-programs";
    ".cargo/registry" = inCache "cargo-registry";
    ".cargo/bin" = "%D/cargo/bin";
  };

  notOnMac = lib.mkIf (!pkgs.stdenv.hostPlatform.isMacOS);
in
{
  module-for = [
    "hm"
    "nixos"
    # mac does not have neither proper xdg, nor systemd, but who cares
    "darwin"
  ];

  systemd.user.tmpfiles.rules = notOnMac (
    builtins.concatMap (
      source:
      let
        target = fromHomeSymlinkDirs.${source};
        mkdir = "d ${target} 0755 - - -";
        mkSymlink = "L+ %h/${source} - - - - ${target}";
      in
      [
        mkdir
        mkSymlink
      ]
    ) (builtins.attrNames fromHomeSymlinkDirs)
  );
  install.sessionVariables = notOnMac {
    GOPATH = "$HOME/.local/share/go";
    GOMODCACHE = "$HOME/.cache/go-mod";
    ANDROID_AVD_HOME = "$HOME/.cache/android-avd";
  };
}

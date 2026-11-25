{ pkgs, lib, ... }: {
  module-for = [ "hm" ];

  install.packages =
    with pkgs;
    (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      plexamp # <- it exists, but not in nix
    ]);
}

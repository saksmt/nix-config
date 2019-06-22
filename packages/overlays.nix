{ config, pkgs, ... }: {
    nixpkgs.overlays = [( self: super: with super.lib; {
        plex = super.plex.overrideAttrs(old: rec {
            name = "plex-${version}";
            version = "1.16.0.1226";
            vsnHash = "7eb2c8f6f";
            sha256 = "1cav5lhpg5ma6s0hkpn8vrdgpy4b9q10qc1vb3j4w7ls9v160g3n";

            src = super.fetchurl {
              url = "https://downloads.plex.tv/plex-media-server-new/${version}-${vsnHash}/redhat/plexmediaserver-${version}-${vsnHash}.x86_64.rpm";
              inherit sha256;
            };
        });
    })];
}

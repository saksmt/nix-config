{ config, pkgs }: {
    nixpkgs.overlays = [( self: super: {
        plex = super.plex.overrideAttrs(old: rec {
            name = "plex-${version}";
            version = "1.16.0.1226";
            vsnHash = "7eb2c8f6f";
            sha256 = "8ee806f35ccedcecd0cab028bbe1f7e2ac7de24292b715978d3165c4712f5c40";

            src = fetchurl {
              url = "https://downloads.plex.tv/plex-media-server/${version}-${vsnHash}/plexmediaserver-${version}-${vsnHash}.x86_64.rpm";
              inherit sha256;
            }
        });
    })];
}
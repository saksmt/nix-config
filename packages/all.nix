with (import ../lib/fp.nix);

{ config, pkgs, ... }: let packagePaths = [

    { freshBazel = "build-tools/bazel"; args = {
        buildJdk = pkgs.jdk8;
        buildJdkName = "jdk8";
        runJdk = pkgs.jdk11;
    }; }

    { freshPlex = "servers/plex"; args = {
        plexRaw = pkgs.callPackage ./servers/plex/raw.nix;
    }; }

];

in {
    nixpkgs.config.packageOverrides = super: let
        self = super.pkgs;
        splitString = super.lib.splitString;
        last = super.lib.last;
        foldl = super.lib.foldl;
        trace = builtins.trace;
        toNameValuePairs = s: builtins.attrValues (super.lib.mapAttrs super.lib.nameValuePair s);
        mkSet = k: v: builtins.listToAttrs [ (super.lib.nameValuePair k v) ];
        listToArgs = flatMap (p: if (builtins.isString p) then {
            name = last (splitStrings "/" p);
            path = "./${p}/default.nix";
            args = {};
        } else (
            let args = if builtins.hasAttr "args" p then p.args else {};
                data = builtins.removeAttrs p ["args"];
            in
            map ({name, value}: {
                inherit name args;
                path = "./${value}/default.nix";
            }) (toNameValuePairs data) )
        );

        result = concatSets (map ({ name, path, args }: mkSet name (pkgs.callPackage (./. + "/${path}") args)) (listToArgs packagePaths));

    in result;
}

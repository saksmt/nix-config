{ nixpkgs, self, ... }:
{
  process-recipe =
    {
      installation ? { },
      ...
    }:
    {
      modules =
        let
          inherit (nixpkgs) lib;
          enabledSets = installation.package-sets or [ ];
          packageSetRoot = self.outPath + "/package-sets";
          pair = a: b: {
            fst = a;
            snd = b;
          };
          fst = { fst, ... }: fst;
          snd = { snd, ... }: snd;
          pairWith = f: v: pair v (f v);
          mapSnd = f: pair: pair // { snd = f pair.snd; };

          allNixFiles =
            let
              r = builtins.map (mapSnd (lib.strings.removePrefix "/")) (
                builtins.map (pairWith (lib.strings.removePrefix packageSetRoot)) (
                  builtins.filter (it: lib.strings.hasSuffix ".nix" it) (
                    lib.filesystem.listFilesRecursive packageSetRoot
                  )
                )
              );
            in
            r;
          validFileReferences = builtins.map (mapSnd (lib.strings.removeSuffix ".nix")) allNixFiles;
          validDirectoryReferences = builtins.map (mapSnd (lib.strings.removeSuffix "/default.nix")) (
            builtins.filter ({ snd, ... }: lib.strings.hasSuffix "/default.nix" snd) allNixFiles
          );
          validReferences =
            (lib.lists.unique (validDirectoryReferences ++ validFileReferences)) ++ allNixFiles;
          validReferenceNames = builtins.map snd validReferences;

          unknownSets = builtins.filter (it: !(builtins.elem it validReferenceNames)) enabledSets;
          filesToInclude =
            if builtins.length unknownSets > 0 then
              throw ''
                Attempted to include unknown package set${
                  lib.strings.optionalString (builtins.length unknownSets > 1) "s"
                }:
                ${builtins.concatStringsSep "\n" unknownSets}


                Known package set names:
                ${builtins.concatStringsSep "\n" validReferenceNames}
              ''
            else
              builtins.concatMap (
                { fst, snd }: lib.lists.optional (builtins.elem snd enabledSets) fst
              ) validReferences;
        in
        builtins.map (import) filesToInclude;
    };
}

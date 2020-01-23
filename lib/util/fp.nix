let lib = (import <nixpkgs>).lib; in {
    flatMap = f: xs: builtins.foldl' (a: b: a ++ b) [] (builtins.map f xs);
    concatSets = builtins.foldl' (a: b: a // b) {};
    flip = f: x: y: (f y) x;
}

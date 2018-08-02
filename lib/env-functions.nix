let
    uses = import ./uses.nix;
    env = import ../env.nix;
    flatMap = f: xs: builtins.foldl' (a: b: a ++ b) [] (builtins.map f xs);
    deps = flag: builtins.foldl' (
        acc: current: acc ++ (
            if (current.value == flag)
            then [flag] ++ (flatMap deps (current.extends or []))
            else []
        )
    ) [] uses;
    allEnabledUses = flatMap deps env.use;
    use = flag: builtins.elem flag allEnabledUses;
    genWhen = flag: data: if (use flag) then data else {};
    genWhenNot = flag: data: if (use flag) then {} else data;
    mkResult = prefix: gen: builtins.foldl' (
        acc: elem: acc // { "${prefix}${elem.name}" = (gen (elem.value or elem.name)); }
    ) {} uses;

in ((mkResult "when" genWhen) // (mkResult "whenNot" genWhenNot)) // { inherit use; }
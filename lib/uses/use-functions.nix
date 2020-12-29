{ conf, ... }: stdNix:

with (import ../util/fp.nix);

let
    lib = stdNix.lib;
    uses = import ./use-definitions.nix;
    deps = flag: builtins.foldl' (
        acc: current: acc ++ (
            if (current.value == flag)
            then [flag] ++ (flatMap deps (current.extends or []))
            else []
        )
    ) [] uses;
    allEnabledUses = flatMap deps conf.use;
    use = flag: builtins.elem flag allEnabledUses;
    genWhen = flag: data: if (use flag) then data else {};
    genWhenNot = flag: data: if (use flag) then {} else data;
    all = sets: builtins.foldl' lib.recursiveUpdate {} sets;
    mkResult = prefix: gen: builtins.foldl' (
        acc: elem: acc // { "${prefix}${elem.name}" = (gen (elem.value or elem.name)); }
    ) {} uses;

in ((mkResult "when" genWhen) // (mkResult "whenNot" genWhenNot)) // {
    inherit use all;
    when = flags: data: if (lib.all use flags) then data else {};
    whenNot = flags: data: if (lib.all (x: !use x) flags) then data else {};
}

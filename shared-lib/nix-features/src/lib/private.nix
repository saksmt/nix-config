## See documentation and types in ./typedefs.d.ts#"nix-features#nixLibs._PRIVATE"
{
  lib ? {
    attrsets = {
      foldlAttrs =
        f: init: set:
        builtins.foldl' (acc: name: f acc name set.${name}) init (builtins.attrNames set);
    };
  },
  ...
}:

rec {
  construct-definitions =
    { feature-definitions }:
    let
      unpathed = feature-definitions {
        inherit self;

        feature =
          {
            default-enabled ? false,
            includes ? [ ],
          }:
          {
            inherit default-enabled includes;
            _type = "feature";
          };
      };
      enabled-feature = {
        is-enabled = true;
      };
      disabled-feature = {
        is-enabled = false;
      };
      mk-feature =
        path: def:
        def
        // enabled-feature
        // rec {
          disable =
            def
            // disabled-feature
            // {
              feature-path = path;
            };
          disabled = disable;
          feature-path = path;
        };
      to-final =
        current-path: attrs:
        if (builtins.isAttrs attrs) then
          if (isFeature attrs) then
            { ok = mk-feature current-path attrs; }
          else
            lib.attrsets.foldlAttrs
              (
                { ok, fail }:
                name: value:
                let
                  child-result = to-final (current-path ++ [ name ]) value;
                in
                {
                  ok = ok // (if (builtins.hasAttr "ok" child-result) then { ${name} = child-result.ok; } else { });
                  fail = fail ++ (child-result.fail or [ ]);
                }
              )
              {
                ok = { };
                fail = [ ];
              }
              attrs
        else
          {
            fail = [
              {
                path = current-path;
                value = attrs;
                reason = "invalid feature definition";
              }
            ];
          };
      result = to-final [ ] unpathed;
      self = result.ok or { };
    in
    result;

  isFeature = a: builtins.isAttrs a && (a._type or "") == "feature";

  sameFeature =
    a: b:
    (isFeature a)
    && (isFeature b)
    && (builtins.hasAttr "feature-path" a)
    && (builtins.hasAttr "feature-path" b)
    && a.feature-path == b.feature-path;

  mapTreeWithPath =
    f: tree:
    let
      go =
        f: currentPath: tree:
        if (isFeature tree) then
          f currentPath tree
        else if (builtins.isAttrs tree) then
          lib.attrsets.foldlAttrs (
            acc: name: value:
            acc // { ${name} = (go f (currentPath ++ [ name ]) value); }
          ) { } tree
        else
          { };
    in
    go f [ ] tree;

  mapTree = f: mapTreeWithPath (_: f);

  treeValues =
    tree:
    if (isFeature tree) then
      [ tree ]
    else if (builtins.isAttrs tree) then
      lib.attrsets.foldlAttrs (
        acc: _: value:
        acc ++ (treeValues value)
      ) [ ] tree
    else
      [ ];

  inherit
    (rec {
      # hacky private definition of helper function
      _doResolve =
        {
          visited ? [ ],
          filter,
          input-features,
          result ? [ ],
        }:
        if (builtins.length input-features > 0) then
          let
            feature = builtins.head input-features;
            rest = builtins.tail input-features;
            filtered-feature =
              if (isFeature feature && filter feature && !(builtins.elem feature.feature-path visited)) then
                [ feature ]
              else
                [ ];
          in
          _doResolve {
            inherit filter;
            visited = visited ++ (builtins.map (it: it.feature-path) filtered-feature);
            input-features = rest ++ (feature.includes or [ ]);
            result = result ++ filtered-feature;
          }
        else
          result;

      resolveDependencies =
        filter: feature:
        _doResolve {
          inherit filter;
          input-features = [ feature ];
        };

      resolveAllDependencies =
        filter: input-features:
        _doResolve {
          inherit filter input-features;
        };
    })
    resolveDependencies
    resolveAllDependencies
    ;

  resolveTree =
    enabled-features: tree:
    let
      force-disabled = builtins.filter (it: !it.is-enabled) enabled-features;
      force-disabled-paths = builtins.map (it: it.feature-path) force-disabled;
      all-enabled = resolveAllDependencies (
        it: !(builtins.elem it.feature-path force-disabled-paths)
      ) enabled-features;
      all-enabled-paths = builtins.map (it: it.feature-path) all-enabled;
    in
    mapTreeWithPath (
      path: feature:
      feature
      // {
        is-enabled =
          !(builtins.elem path force-disabled-paths)
          && (feature.default-enabled || (builtins.elem path all-enabled-paths));
      }
    ) tree;

  mkUserFacingFeature =
    {
      modules ? lib.modules,
      ...
    }@lib:
    let
      on-is-enabled-syntax =
        { is-enabled, ... }:
        let
          if-enabled = content: lib.modules.mkIf (is-enabled) content;
          is-disabled = !is-enabled;
          if-disabled = content: lib.modules.mkIf (is-disabled) content;
          and =
            other-feature:
            (on-is-enabled-syntax {
              is-enabled = other-feature.is-enabled && is-enabled;
            })
            // {
              _type = "feature-expression";
            };

          or' =
            other-feature:
            (on-is-enabled-syntax {
              is-enabled = other-feature.is-enabled || is-enabled;
            })
            // {
              _type = "feature-expression";
            };
        in
        {
          inherit
            if-enabled
            if-disabled
            is-disabled
            and
            or'
            is-enabled
            ;

          # sugar:
          ifEnabled = if-enabled;
          ifDisabled = if-disabled;

          isEnabled = is-enabled;
          isDisabled = is-disabled;

          are-enabled = is-enabled;
          are-disabled = is-disabled;

          areEnabled = is-enabled;
          areDisabled = is-disabled;

          when-enabled = if-enabled;
          when-disabled = if-disabled;

          whenEnabled = if-enabled;
          whenDisabled = if-disabled;

          or_ = or';
          And = and;
          Or = or';
        };
    in
    feature: feature // (on-is-enabled-syntax feature);
}

let
  # prefixed/namespaced to avoid name clash
  attributeNamespace = "saksmt/nix-unstables";
  sourceLocationKey = "${attributeNamespace}:UNSTABLES_SOURCE";
  refTypeMarker = "${attributeNamespace}:ref";
  foldlAttrs =
    f: init: set:
    builtins.foldl' (acc: name: f acc name set.${name}) init (builtins.attrNames set);
  mk-source = v: v // { ${sourceLocationKey} = "UNINIT"; };
  isSource = a: builtins.isAttrs a && builtins.hasAttr sourceLocationKey a;
  isUninitSource = a: isSource a && a.${sourceLocationKey} == "UNINIT";
  _mapTree =
    current-path: f: tree:
    if isUninitSource tree then
      f current-path tree
    else if builtins.isAttrs tree then
      builtins.mapAttrs (p: v: _mapTree (current-path ++ [ p ]) f v) tree
    else
      tree;
  mapTree = _mapTree [ ];
  isPackageReference = a: builtins.isAttrs a && ((a._type or "") == refTypeMarker);
  packageReferenceProto = {
    _type = refTypeMarker;
  };
  isDerivation = a: builtins.isAttrs a && ((a.type or "") == "derivation");
  getPath =
    sourceName: source: fullPath:
    (builtins.foldl'
      (
        { set, current-path }:
        path:
        if builtins.hasAttr path set then
          {
            set = set.${path};
            current-path = current-path ++ [ path ];
          }
        else
          builtins.throw "Can not find ${
            pathToString (current-path ++ [ path ])
          } in ${pathToString sourceName}"
      )
      {
        set = source;
        current-path = [ ];
      }
      fullPath
    ).set;
  from =
    v:
    packageReferenceProto
    // (
      if builtins.isAttrs v && (v.${sourceLocationKey} or false) != false then
        {
          get = getPath v.${sourceLocationKey} v;
        }
      else
        {
          get = path-to-attr: v;
        }
    );
  copy-of =
    v:
    packageReferenceProto
    // {
      get = _: if builtins.isAttrs v then builtins.removeAttrs v [ sourceLocationKey ] else v;
    };
  pathToString =
    path:
    if builtins.isString path then
      path
    else if builtins.isList path then
      builtins.concatStringsSep "." path
    else
      builtins.throw "Invalid path: ${path}";
  throwUnexpcetedValue =
    p: tpe:
    builtins.throw "Unexpected value of type ${tpe} at ${pathToString p}. Did you forget to call from?";
  run =
    current-path: overrides: prev:
    if isPackageReference overrides then
      overrides.get current-path
    else if isDerivation overrides then
      throwUnexpcetedValue current-path "derivation"
    else if isSource overrides then
      throwUnexpcetedValue current-path "<package source: (${
        pathToString overrides.${sourceLocationKey}
      } in source tree)>"
    else if builtins.isAttrs overrides then
      foldlAttrs (
        acc: name: v:
        acc // { ${name} = run (current-path ++ [ name ]) v (acc.${name} or { }); }
      ) prev overrides
    else
      throwUnexpcetedValue current-path (builtins.typeOf overrides);
in
{
  inherit isSource isUninitSource;
  mapUninitTree = mapTree;
  define-source = mk-source;
  make-source-tree = mapTree (path: value: value // { ${sourceLocationKey} = path; });
  compile-unstables-config = source-tree: config: config (source-tree // { inherit from copy-of; });
  overlay =
    compiled-config: prev: final:
    run [ ] compiled-config final;

  __PRIVATE__ = {
    inherit sourceLocationKey refTypeMarker attributeNamespace;
  };
}

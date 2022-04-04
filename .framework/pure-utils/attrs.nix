with builtins;

{
  attrOr = name: default: attrs: if hasAttr name attrs then getAttr name attrs else default;
}
with builtins;

{
  startsWith = string: prefix:
    let
      prefixLen = stringLength prefix;
    in prefixLen <= stringLength string && prefix == (substring 0 prefixLen string)
  ;
  endsWith = string: suffix:
    let
      suffixLen = stringLength suffix;
      stringLen = stringLength string;
    in
      suffixLen <= stringLen && suffix == (substring (stringLen - prefixLen) prefixLen)
    ;
}
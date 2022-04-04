{ conf, currentPkgs, ... } : stdNix:

with conf;
with builtins;

let
  traversePluginSettings = pkgs: pluginSettings: missingPackages: currentPath:
    if isAttrs pluginSettings then 
      foldl' (currentResult: nextPkgName:
        if hasAttr nextPkgName pkgs then 
          let nextResult = traversePluginSettings (getAttr nextPkgName pkgs) (getAttr nextPkgName pluginSettings) [] "${currentPath}.${nextPkgName}";
          in {
            right = currentResult.right // { "${nextPkgName}" = nextResult.right; };
            left  = currentResult.left ++ nextResult.left;
          }
        else {
          right = currentResult.right;
          left = currentResult.left ++ [ "${currentPath}.${nextPkgName}" ];
        }
      ) { left = missingPackages; right = {}; } (attrNames pluginSettings)
    else if isList pluginSettings then {
      left = missingPackages;
      right = pkgs.override { plugins = pluginSettings; };
    } else {
      left = missingPackages;
      right = null;
    }
  ;
  result = traversePluginSettings currentPkgs (conf.plugins stdNix.pkgs) [] "pkgs";
in
  if length result.left > 0 then 
    throw "Can't configure plugins since those paths are missing:\n${foldl' (a: b: "  ${a}\n  ${b}") "" result.left}"
  else result.right


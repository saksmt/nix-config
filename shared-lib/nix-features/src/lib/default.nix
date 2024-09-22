## See documentation and types in ./typedefs.d.ts#"nix-features#nixLibs.default"

nixpkgs:
let
  internal-lib = import ./private.nix nixpkgs;
in
with internal-lib;
rec {
  define-features-or-throw =
    feature-definitions:
    let
      inherit (nixpkgs) lib;
      defined-features-and-fails = define-features feature-definitions;
      error-message = format-definition-error-message defined-features-and-fails.fail;
      defined-features = lib.trivial.throwIf (
        builtins.length (defined-features-and-fails.fail or [ ]) > 0
      ) error-message defined-features-and-fails.ok;
    in
    defined-features;

  define-features =
    feature-definitions:
    let
      result = construct-definitions { inherit feature-definitions; };
    in
    if (builtins.hasAttr "fail" result && builtins.length result.fail > 0) then
      builtins.removeAttrs result [ "ok" ]
    else
      builtins.removeAttrs result [ "fail" ];

  _assign-features =
    libOverride: defined-features: enabled-list:
    let
      resolvedTree = resolveTree enabled-list defined-features;
      userFacingTree = mapTree (mkUserFacingFeature libOverride) resolvedTree;
    in
    userFacingTree;

  assign-features = _assign-features nixpkgs.lib;

  format-definition-error-message =
    definition-errors:
    let
      inherit (nixpkgs) lib;
      error-messages = builtins.map (
        {
          reason,
          path,
          value,
        }:
        "${reason} at path [${lib.attrsets.showAttrPath path}] with value: ${
          lib.generators.toPretty { } value
        }"
      ) definition-errors;
    in
    builtins.concatStringsSep "\n" error-messages;
}

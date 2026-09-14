{
  inputs,
  self,
  ...
}@resolvedInputs: outputs:
let
  versionedInputs = builtins.mapAttrs (
    k: v: v // (if k == "self" || k == "inputs" then { } else { source = inputs.${k}; })
  ) resolvedInputs;
in
{
  inputs = versionedInputs;
  inherit outputs;
  inherit self;
  sourceInputs = inputs;
  inputVersions = builtins.mapAttrs (
    k: v:
    let
      source = if builtins.isString v.source.url then builtins.parseFlakeRef v.source.url else v.source;
    in
    {
      name = k;
      branch =
        if source ? "ref" then
          source.ref
        else if
          builtins.elem source.type [
            "git"
            "github"
            "gitlab"
          ]
        then
          "<default-branch>"
        else
          null;
      commit = v.shortRev;
      updatedAt = v.lastModified;
    }
  ) (builtins.removeAttrs versionedInputs [ "self" ]);
}
// builtins
// resolvedInputs.nixpkgs.lib

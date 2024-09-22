_: {
  process-recipe =
    cfg:
    let
      dropped-installation = builtins.removeAttrs cfg [ "installation" ];
    in
    {
      modules = [ (_: dropped-installation) ];
    };
}

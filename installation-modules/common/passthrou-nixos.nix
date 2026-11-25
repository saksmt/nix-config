_: {
  process-recipe =
    cfg:
    let
      dropped-installation = builtins.removeAttrs cfg [
        "installation"
        "per-user"
      ];
    in
    {
      modules = [ (_: dropped-installation) ];
    };
}

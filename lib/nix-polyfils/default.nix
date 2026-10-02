let
  polyfils = [
    "emacs"
    "packages"
    "shells"
    "fonts"
    "catppuccin"
    "git-delta"
  ];

  validatorF = import ./src/module-type-validator.nix;
  validator = {
    nixosModule = validatorF "nixos";
    homeManagerModule = validatorF "hm";
    darwinModule = validatorF "darwin";
  };

  def =
    tpe:
    let
      includeModule = moduleName: import (./src/${moduleName}.module.nix);
      modules = builtins.map includeModule polyfils;

    in
    {
      default = _: {
        imports = builtins.map (module: module.${tpe} or (_: { })) (modules ++ [ validator ]);
      };
      module-type-validator = validator.${tpe};
    }
    // (builtins.listToAttrs (
      builtins.map (moduleName: {
        name = moduleName;
        value = (includeModule modules).${tpe} or (_: { });
      }) polyfils
    ));
in
{
  nixosModules = def "nixosModule";
  homeManagerModules = def "homeManagerModule";
  darwinModules = def "darwinModule";
}

let
  emacs = import ./src/emacs.module.nix;
  packages = import ./src/packages.module.nix;
  shells = import ./src/shells.module.nix;
  fonts = import ./src/fonts.module.nix;
  nix = import ./src/nix.module.nix;
  catppuccin = import ./src/catppuccin.module.nix;
  git-delta = import ./src/git-delta.module.nix;

  validatorF = import ./src/module-type-validator.nix;
  validator = {
    nixosModule = validatorF "nixos";
    homeManagerModule = validatorF "hm";
  };

  def = tpe: {
    default = _: {
      imports = [
        (emacs.${tpe})
        (packages.${tpe})
        (shells.${tpe})
        (fonts.${tpe})
        (nix.${tpe})
        (catppuccin.${tpe})
        (git-delta.${tpe})

        (validator.${tpe})
      ];
    };

    emacs-adapter = emacs.${tpe};
    packages-adapter = packages.${tpe};
    shells-adapter = shells.${tpe};
    fonts-adapter = fonts.${tpe};

    module-type-validator = validator.${tpe};
  };
in
{
  nixosModules = def "nixosModule";
  homeManagerModules = def "homeManagerModule";
}

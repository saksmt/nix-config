{ feature-definitions, ... }:
{
  home.username = "deck";
  home.homeDirectory = "/home/deck";

  programs.git = {
    userName = "Kirill Saksin";
    userEmail = "smt@saksmt.dev";
  };

  installation = {
    unstables =
      {
        from,
        unstable,
        master,
        copy-of,
        ...
      }:
      {
        unstable = copy-of unstable;
      };

    features = with feature-definitions; [
      GUI

      laptop

      dev.nix
    ];

    package-sets = [
      "cli"
      "dev/nix"
      "dev/common"

      "user-preferences"
    ];

  };

  imports = [
    (
      { pkgs, ... }:
      {
        home.stateVersion = "24.05";
        home.packages = [ pkgs.android-tools ];
      }
    )
  ];
}

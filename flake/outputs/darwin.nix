recipe-loader:
let
  darwinFromInstallationModules =
    path:
    (recipe-loader.load-and-process {
      modules = [ "/installation-modules/darwin" ];
      recipe-path = path;
    }).as-darwin;
in
{
  work-mac = darwinFromInstallationModules "/hosts/work-mac.nix";
}

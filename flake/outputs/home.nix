recipe-loader:
let
  hmFromInstallationModules =
    path:
    (recipe-loader.load-and-process {
      modules = [ "/installation-modules/hm/standalone.nix" ];
      recipe-path = path;
    }).as-hm
      "x86_64-linux";
in
{
  work-laptop = hmFromInstallationModules "/hosts/no-host/work-laptop.hm.nix";
  deck = hmFromInstallationModules "/hosts/no-host/deck.hm.nix";
}

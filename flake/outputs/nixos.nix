recipe-loader:
let
  nixosFromInstallationModules =
    path:
    (recipe-loader.load-and-process {
      modules = [ "/installation-modules/nixos" ];
      recipe-path = path;
    }).as-nixos;
in
{
  smt-laptop = nixosFromInstallationModules "/hosts/laptop.nix";
  nas = nixosFromInstallationModules "/hosts/nas.nix";
}

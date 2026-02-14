# this iso is not intended to be used for anything other than testing grub
# the only capabilities it has to have to be able to boot and reboot
{
  feature-definitions,
  ...
}:
rec {

  installation.make-image.modules = [
    "minimal/minimal-functional.nix"
  ];

  imports = [
    (
      {
        pkgs,
        lib,
        modulesPath,
        ...
      }:
      {
        images.iso = {
          base-name = "grub-test";
          volumeID = "GRUB_TEST";
          applicationID = "GRUB_TEST";
          publisher = "SAKSMT";

          efiBootEntryName = "Grub test";

          boot.entryname = "Boot to reboot";
        };
        # we don't actually care much about disk space
        # speed matters more
        images.squashfs.compression = "lz4 -b 32768";

        programs.nix-index.enable = lib.mkForce false;
        programs.nix-index-database.comma.enable = lib.mkForce false;
        programs.git.enable = false;

        users.users.root.initialHashedPassword = "";
        security.polkit.enable = false;

        networking.hostName = "rebootme";
        networking.hosts = {
          "127.0.0.1" = [ "rebootme" ];
        };
        boot.blacklistedKernelModules = [
          "nouveau"
        ];

      }
    )
  ];

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
      GUI.disable
    ];

    package-sets = [
    ];

    home-manager.enabled = false;
  };
}

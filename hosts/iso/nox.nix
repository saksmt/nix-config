{
  feature-definitions,
  ...
}:
rec {

  installation.make-image.modules = [
    "minimal"
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
          base-name = "nox-${lib.trivial.release}";
          volumeID = "PORTABLE_NIXOS_NOX";
          applicationID = "PORTABLE_NIXOS_NOX";

          efiBootEntryName = "NOX NixOS LiveCD";

          boot.entryname = "Boot to NOX NixOS";
        };

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

      android
      dev.common
      dev.nix
    ];

    package-sets = [
      "system/hardware/android"
      "system/hardware/yubikey"
      "system/base"

      "system/iso"

      "tools/hardware-tools"
      "tools/rescue-tools"

      "cli"
      "dev"
    ];

    home-manager = {
      enabled = true;

      # force management of zshrc and stuff through home-manager
      programs.zsh.enable = true;

      programs.git = {
        userName = "Kirill Saksin";
        userEmail = "smt@saksmt.dev";
      };

      installation = {
        package-sets = [
          "user-preferences"
        ];
        features = installation.features;
      };
    };
  };
}

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
          base-name = "minimal-nox-${lib.trivial.release}";
          volumeID = "PORTABLE_NIXOS_NOX";
          applicationID = "PORTABLE_NIXOS_NOX";

          efiBootEntryName = "Minimal NOX NixOS LiveCD";
          efiBootEntryVersion = lib.trivial.release;

          boot.entryname = "Boot to Minimal NOX NixOS";
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
    ];

    package-sets = [
      "system/hardware/android"
      "system/hardware/yubikey"
      "system/base"

      "system/iso"

      "tools/hardware-tools"

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

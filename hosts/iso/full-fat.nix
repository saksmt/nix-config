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
        lib,
        ...
      }:
      {
        images.iso = {
          base-name = "full-fat-${lib.trivial.release}";

          efiBootEntryName = "Full Fat NixOS LiveCD";

          volumeID = "PORTABLE_FAT_NIXOS";
          applicationID = "PORTABLE_FAT_NIXOS";

          boot.entryname = "Boot to Full Fat Custom NixOS";
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
        jetbrains.idea = from master;
        wrapOBS = from unstable;
        obs-studio-plugins = from unstable;

        unstable = copy-of unstable;
      };

    features = with feature-definitions; [
      GUI

      work
      dev.all
      android
    ];

    package-sets = [
      "system/hardware/android"
      "system/hardware/guitar"
      "system/hardware/keyboard"
      "system/hardware/yubikey"
      "system/base"
      "system/virtual-camera"

      "system/iso"
      "system/vm-guest"

      "tools/hardware-tools"

      "runtime/docker"
      "runtime/jvm"

      "cli"
      "dev"

      "gui/setup/base"
      "gui/setup/sddm"
      "gui/setup/xorg"
    ];
    home-manager = {
      enabled = true;

      # force management of zshrc and stuff through home-manager
      programs.zsh.enable = true;

      programs.git = {
        userName = "Kirill Saksin";
        userEmail = "smt@saksmt.dev";
      };

      windowManager.awesome-iwm.enable = true;

      installation = {
        package-sets = [
          "gui/apps/base"
          "gui/apps/dev"
          "gui/apps/im"
          "gui/apps/media-editing"
          "gui/apps/players"
          "gui/apps/streaming"

          "gui/setup/fonts"
          "gui/themes"
          "gui/window-managers/awesome"

          "user-preferences"
        ];
        features = installation.features;
      };
    };
  };
}

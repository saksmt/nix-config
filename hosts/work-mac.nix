{ feature-definitions, ... }:
rec {
  imports = [
    (
      { pkgs, ... }:
      {
        system.stateVersion = "26.05";
      }
    )
  ];

  home-manager.users."Kirill.Saksin" =
    { pkgs, ... }:
    {
      home.stateVersion = "26.05";
    };

  networking.hostName = "LMCWY27DP";

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
        gemini-cli = from master;
        opencode = from master;
        opencode-desktop = from master;

        unstable = copy-of unstable;
      };

    features = with feature-definitions; [
      GUI

      laptop

      work
      work-ban

      dev.scala
      dev.jvm-other
      dev.nix
      dev.k8s

      HiDPI
    ];

    package-sets = [
      "system/fonts"
    ];

    home-manager = {
      enabled = true;

      # force management of zshrc and stuff through home-manager
      programs.zsh.enable = true;

      programs.git = {
        enable = true; # force management of git config through home-manager
        userName = "Kirill Saksin";
        userEmail = "kirill.saksin@ringcentral.com";
      };

      installation = {
        package-sets = [
          "runtime/jvm"

          "cli"

          "gui/apps/base"
          "gui/apps/dev"

          "gui/apps/players"

          "user-preferences"

          "dev"
          "dev/ai"
        ];
        features = installation.features;
      };

      imports = [
        (
          {
            pkgs,
            jail,
            lib,
            host-config,
            ...
          }:
          {
            opencode.plugins.octto.settings = {
              agents = {
                probe.model = "opencode/big-pickle";
                bootstrapper.model = "opencode/big-pickle";
              };
            };
          }
        )
      ];
    };
  };
}

{ feature-definitions, ... }:
{
  home.username = "kirillsaksin";
  home.homeDirectory = "/home/kirillsaksin";

  programs.git = {
    userName = "Kirill Saksin";
    userEmail = "kirill.saksin@ringcentral.com";
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
        jetbrains.idea = from master;

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
    ];

    package-sets = [
      "runtime/jvm"

      "cli"
      "dev"

      "gui/apps/base"
      "gui/apps/dev"
      "gui/apps/im"
      "gui/apps/players"

      "gui/setup/fonts"
      "gui/themes"
      "gui/window-managers/awesome"

      "user-preferences"
    ];

    nix-gl = {
      enabled = true;
      wrapper-script-prefix = pkgs: "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel";
    };
  };

  imports = [
    (
      { pkgs, ... }:
      {
        home.stateVersion = "24.05";
        # This enables propagation of XDG and other profile variables
        # through systemd environment, which is imported by default
        # in xsession
        targets.genericLinux.enable = true;
        home.packages = [ pkgs.nixgl.nixGLIntel ];

        programs.kitty.package = pkgs.nix-gl-wrap pkgs.kitty;
        services.xscreensaver.package = pkgs.nix-gl-wrap pkgs.xscreensaver;
        programs.firefox.package = pkgs.nix-gl-wrap pkgs.firefox;
      }
    )
  ];
}

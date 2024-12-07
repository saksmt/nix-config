{ feature-definitions, ... }:
{
  home.username = "kirillsaksin";
  home.homeDirectory = "/home/kirillsaksin";

  programs.git = {
    userName = "Kirill Saksin";
    userEmail = "kirillsaksin@ringcentral.com";
  };

  installation = {
    unstables =
      {
        from,
        unstable,
        copy-of,
        ...
      }:
      {
        jetbrains.idea-ultimate = from unstable;

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
  };

  imports = [
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/nix-community/home-manager/830c928697049ef9ce1eea2f3b6ce2972a80b6f6/modules/misc/nixgl.nix";
      sha256 = "01dkfr9wq3ib5hlyq9zq662mp0jl42fw3f6gd2qgdf8l8ia78j7i";
    })
    (
      { pkgs, config, ... }:
      {
        home.packages = [ pkgs.nixgl.nixGLIntel ];
        nixGL.prefix = "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel";

        programs.kitty.package = config.lib.nixGL.wrap pkgs.kitty;
        services.xscreensaver.package = config.lib.nixGL.wrap pkgs.xscreensaver;
        programs.firefox.package = config.lib.nixGL.wrap pkgs.firefox;
      }
    )
  ];
}

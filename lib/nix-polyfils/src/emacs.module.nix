{
  nixosModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    with lib;
    let
      clientDesktopItem = pkgs.writeTextDir "share/applications/emacsclient.desktop" (
        generators.toINI { } {
          "Desktop Entry" = {
            Type = "Application";
            Exec = "${config.services.emacs.package}/bin//emacsclient ${concatStringsSep " " config.services.emacs.client.arguments} %F";
            Terminal = false;
            Name = "Emacs Client";
            Icon = "emacs";
            Comment = "Edit text";
            GenericName = "Text Editor";
            MimeType = "text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;";
            Categories = "Development;TextEditor;";
            Keywords = "Text;Editor;";
            StartupWMClass =
              if versionAtLeast (getVersion config.services.emacs.package) "28" then "Emacsd" else "Emacs";
          };
        }
      );
    in
    {
      options.services.emacs.client = {
        enable = mkEnableOption "generation of Emacs client desktop file";
        arguments = mkOption {
          type = with types; listOf str;
          default = [ "-c" ];
          description = ''
            Command-line arguments to pass to {command}`emacsclient`.
          '';
        };
      };
      config.environment.systemPackages = optional config.services.emacs.client.enable clientDesktopItem;
    };
  homeManagerModule = { config, lib, ... }: { };
}

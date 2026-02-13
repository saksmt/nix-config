{ pkgs, ... }: {
  environment.systemPackages = [(
    pkgs.writeShellApplication {
      name = "iso-repl";
      text = ''
      nix repl --extra-experimental-features 'flakes repl-flake' built-os#repl "''${@}"
      '';
    }
  )];
}
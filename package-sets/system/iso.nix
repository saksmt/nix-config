# Not included in aggregate
{
  config,
  flake-inputs,
  pkgs,
  lib,
  ...
}:
let
  impure = builtins ? currentSystem;
  repoPath = if impure then builtins.getEnv "THIS_FLAKE_REPO" else "";
  repo = if repoPath == "" then flake-inputs.self else lib.fileset.toSource {
    root = /. + repoPath;
    fileset = lib.fileset.union (lib.fileset.gitTracked (/. + repoPath)) (/. + repoPath + "/.git");
  };
  sshKeysEnvVar = if impure then builtins.getEnv "INCLUDED_SSH_KEYS" else "";
  sshKeys = builtins.map (it: /. + it) (lib.uniqueStrings (builtins.filter (it: it != "") (builtins.map lib.trim (lib.splitString ":" sshKeysEnvVar))));
in {
  module-for = [ "nixos" ];

  images.iso = {
    publisher = "SAKSMT";

    contents = [
      {
        source = repo;
        target = "/saksmt-nix-config";
      }
    ];
  };
  boot.postBootCommands = ''
    cp -R /iso/saksmt-nix-config /home/smt/nix-config
    chown -R smt:users /home/smt/nix-config
    chmod -R ug+r /home/smt/nix-config
    chmod -R u+w /home/smt/nix-config

    for o in $(</proc/cmdline); do
      case "$o" in
        live.nixos.passwd=*)
          set -- $(IFS==; echo $o)
          echo "smt:$2" | ${pkgs.shadow}/bin/chpasswd
          ;;
      esac
    done
  '';

  # this works nowhere anyway
  boot.blacklistedKernelModules = [
    "nouveau"
  ];

  users.users.root.shell = pkgs.zsh;
  users.users.smt = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "kvm"
      "adbusers"
      "video"
    ];
    initialHashedPassword = "";
    openssh.authorizedKeys.keyFiles = sshKeys;
  };
  home-manager.users.smt = { config, ... }: {
    home.stateVersion = config.home.version.release;
    home.activationGenerateGcRoot = false;
  };

  security.pam.services = {
    login.allowNullPassword = true;
    sddm.allowNullPassword = true;
  };

  services.getty.autologinUser = lib.mkForce "smt";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "smt";

  # Whitelist wheel users to do anything
  # This is useful for things like pkexec
  #
  # WARNING: this is dangerous for systems
  # outside the installation-cd and shouldn't
  # be used anywhere else.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  networking.hostName = "nixos-live";
  networking.hosts = {
    "127.0.0.1" = [ "nixos-live" ];
  };

  networking.networkmanager.enable = true;
  services.upower.enable = true;

  services.openssh.settings = {
    # force logging in with keys and only for smt
    AllowUsers = [ "smt" ];
    PasswordAuthentication = false;
  };

  images.iso.nix-store-contents = [ config.home-manager.users.smt.home.activationPackage ];
}

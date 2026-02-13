# This module contains the basic configuration for building a NixOS
# installation CD.
{
  config,
  lib,
  options,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    ./barebones.nix

    (modulesPath + "/profiles/base.nix")
    # Enable devices which are usually scanned, because we don't know the
    # target system.
    (modulesPath + "/installer/scan/detected.nix")
    (modulesPath + "/installer/scan/not-detected.nix")

    # Include a copy of Nixpkgs so that nixos-install works out of
    # the box.
    # todo: this does not work - nix-env fails to install package from path in store
    (modulesPath + "/installer/cd-dvd/channel.nix")
  ];

  images.iso.boot.grub.theme = config.catppuccin.sources.grub + "/share/grub/themes/catppuccin-${config.catppuccin.flavor}-grub-theme";

  # Enable in installer, even if the minimal profile disables it.
  documentation.enable = lib.mkImageMediaOverride true;

  # Show the manual.
  documentation.nixos.enable = lib.mkImageMediaOverride true;

  hardware.enableAllHardware = true;

  system.nixos.variant_id = lib.mkDefault "installer";

  # An installation media cannot tolerate a host config defined file
  # system layout on a fresh machine, before it has been formatted.
  swapDevices = lib.mkImageMediaOverride [ ];
  fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;
  boot.initrd.luks.devices = lib.mkImageMediaOverride { };

  # Allow the user to log in as root without a password.
  users.users.root.initialHashedPassword = "";

  # Don't require sudo/root to `reboot` or `poweroff`.
  security.polkit.enable = true;

  # Allow passwordless sudo from nixos user
  security.sudo = {
    enable = lib.mkDefault true;
    wheelNeedsPassword = lib.mkImageMediaOverride false;
  };

  # We run sshd by default. Login is only possible after adding a
  # password via "passwd" or by adding a ssh key to ~/.ssh/authorized_keys.
  # The latter one is particular useful if keys are manually added to
  # installation device for head-less systems i.e. arm boards by manually
  # mounting the storage in a different system.
  services.openssh = {
    enable = lib.mkDefault true;
    settings.PermitRootLogin = lib.mkDefault "yes";
  };

  # Tell the Nix evaluator to garbage collect more aggressively.
  # This is desirable in memory-constrained environments that don't
  # (yet) have swap set up.
  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";

  # Make the installer more likely to succeed in low memory
  # environments.  The kernel's overcommit heustistics bite us
  # fairly often, preventing processes such as nix-worker or
  # download-using-manifests.pl from forking even if there is
  # plenty of free memory.
  boot.kernel.sysctl."vm.overcommit_memory" = "1";

  # To speed up installation a little bit, include the complete
  # stdenvNoCC in the Nix store on the CD.
  system.extraDependencies =
    with pkgs;
    [
      stdenvNoCC # for runCommand
      busybox
      # For boot.initrd.systemd
      makeInitrdNGTool
    ]
    ++ jq.all; # for closureInfo

  boot.swraid.enable = true;
  # remove warning about unset mail
  boot.swraid.mdadmConf = "PROGRAM ${pkgs.coreutils}/bin/true";

  # Show all debug messages from the kernel but don't log refused packets
  # because we have the firewall enabled. This makes installs from the
  # console less cumbersome if the machine has a public IP.
  networking.firewall.logRefusedConnections = lib.mkDefault false;

  # Prevent installation media from evacuating persistent storage, as their
  # var directory is not persistent and it would thus result in deletion of
  # those entries.
  environment.etc."systemd/pstore.conf".text = ''
    [PStore]
    Unlink=no
  '';

  # Install less voices for speechd to save some space
  nixpkgs.overlays = [
    (_: prev: {
      mbrola-voices = prev.mbrola-voices.override {
        # only ship with one voice per language
        languages = [ "*1" ];
      };
    })
  ];

  environment.defaultPackages = with pkgs; [
    rsync
  ];

  programs.git.enable = lib.mkDefault true;

  system.stateVersion = lib.mkDefault lib.trivial.release;
}

# saksmt nixos configuration files

Opinionated nixos configuration with support for somewhat useflags on "world" level, custom ovelaying (see [unstables](./overlays/unstables.nix) as an example)
 and coexistance of stable (stable channel), unstable (nixpkgs-unstable) and even forked packages with deadly simple syntax (see [unstables.nix](./unstables.nix))

Use at your own risk, no guarantees provided whatsoever.

Start by copying `env.nix.tpl` to `env.nix` and modifying it for your own use-cases.

## todo

 - split media-server use flag into smaller pieces
 - drop grub and replace with systemd
 - work out some installation without symlinking

## related

 - [local-bin](https://github.com/saksmt/local-bin)

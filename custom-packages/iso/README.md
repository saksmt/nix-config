This is a hard fork of code from nixpkgs/nixos/modules.

Motivation:
 - something is broken in upstream about usage of xorisso
 - there is no way to swap & fix underlying nixos/lib/make-iso9660-image.sh without hard forking

Submit to upstream?

Probably not. There is no guarantee that my modifications are not broken on something obscure, the same as upstream is broken on my laptop. Also, there are plans to move to systemd-repart and unify all the image-related code in the upstream.

Actual changes pertain to the following files:
 - make-iso9660-image.sh - fix xorisso usage
 - make-iso9660-image.nix – move squashfs creation outside to be able to cache it (does not actually work - every change in anything in nix leads to rebuild...)
 - make-squashfs.nix – make squashfs image name static

TODO:
 - copy iso-base.nix and all the other fluff
 - change it to no longer generate *.img
 - make grub config actually customizable

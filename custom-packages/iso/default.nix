{ pkgs, ... }: {
  iso-file = params: pkgs.callPackage ./make-iso9660-image.nix params;
  squashfs-file = params: pkgs.callPackage ./make-squashfs.nix params;
}

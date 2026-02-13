{
  stdenv,
  closureInfo,
  xorriso,
  grub2_efi,
  mtools,
  syslinux,
  libossp_uuid,

  # The file name of the resulting ISO image.
  isoName ? "cd.iso",

  # The files and directories to be placed in the ISO file system.
  # This is a list of attribute sets {source, target} where `source'
  # is the file system object (regular file or directory) to be
  # grafted in the file system at path `target'.
  contents,

  squashfsImage,

  # In addition to `contents', the closure of the store paths listed
  # in `storeContents' are also placed in the Nix store of the CD.
  # This is a list of attribute sets {object, symlink} where `object'
  # is a store path whose closure will be copied, and `symlink' is a
  # symlink to `object' that will be added to the CD.
  storeContents ? [ ],

  # Whether to compress the resulting ISO image with zstd.
  compressorTemplate ? "",
  zstd,

  # The volume ID. 32 chars max, [A-Z0-9_]
  volumeID ? "",
  # 128 chars max
  applicationID ? "NIXOS",
  # 128 chars max
  publisher ? "NIXOS",
  # --modules :: String[]
  preload-grub-modules ? [],
  # --themes, default "starfield", a bit of a quiz whether it can accept a path or if it is singular or plural
  # --product-name
  productName ? "NIXOS",
  productVersion ? "git"
}:

stdenv.mkDerivation {
  name = isoName;
  __structuredAttrs = true;

  # the image will be self-contained so we can drop references
  # to the closure that was used to build it
  unsafeDiscardReferences.out = true;

  buildCommandPath = ./make-iso9660-image.sh;
  nativeBuildInputs = [
    xorriso
    syslinux
    zstd
    grub2_efi
    libossp_uuid
    mtools
  ];

  preloadModules = builtins.concatStringsSep " " preload-grub-modules;

  inherit
    isoName
    compressorTemplate
    volumeID
    squashfsImage
    productName
    productVersion
    ;

  sources = map (x: x.source) contents;
  targets = map (x: x.target) contents;

  objects = map (x: x.object) storeContents;
  symlinks = map (x: x.symlink) storeContents;

  # For obtaining the closure of `storeContents'.
  closureInfo = closureInfo { rootPaths = map (x: x.object) storeContents; };
}
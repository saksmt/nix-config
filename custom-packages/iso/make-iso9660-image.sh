#<editor-fold desc="Helper functions">

# Remove the initial slash from a path, since genisofs likes it that way.
stripSlash() {
    res="$1"
    if test "${res:0:1}" = /; then res=${res:1}; fi
}

# Escape potential equal signs (=) with backslash (\=)
escapeEquals() {
    echo "$1" | sed -e 's/\\/\\\\/g' -e 's/=/\\=/g'
}

# Queues an file/directory to be placed on the ISO.
# An entry consists of a local source path (2) and
# a destination path on the ISO (1).
addPath() {
    target="$1"
    source="$2"
    echo "$(escapeEquals "$target")=$(escapeEquals "$source")" >> pathlist
}

#</editor-fold>

touch pathlist

#<editor-fold desc="Add all files to the ISO">

echo -n # this echo is a testament to broken folding regions in idea...

# Add the individual files.
for ((i = 0; i < ${#targets[@]}; i++)); do
  stripSlash "${targets[$i]}"
  addPath "$res" "${sources[$i]}"
done


# Add the closures of the top-level store objects.
for i in $(< $closureInfo/store-paths); do
  addPath "${i:1}" "$i"
done

# If it exists add squashfs
if [[ -n "$squashfsImage" ]]; then
  addPath "nix-store.squashfs" "${squashfsImage}"
fi

# Also include a manifest of the closures in a format suitable for
# nix-store --load-db.
if [[ ${#objects[*]} != 0 ]]; then
  cp $closureInfo/registration nix-path-registration
  addPath "nix-path-registration" "nix-path-registration"
fi


# Add symlinks to the top-level store objects.
for ((n = 0; n < ${#objects[*]}; n++)); do
  object=${objects[$n]}
  symlink=${symlinks[$n]}
  if test "$symlink" != "none"; then
    mkdir -p $(dirname ./$symlink)
    ln -s $object ./$symlink
    addPath "$symlink" "./$symlink"
  fi
done

#</editor-fold>

mkdir -p $out/iso

authoringFlags="-volid ${volumeID}
                -appid ${applicationID}
                -publisher ${publisher}"

# carefully copy pasted from gentoo
# important note: ONLY USE grub2_efi, NOT grub2, otherwise ISO will be broken for EFI and will have DOS partition table
# -joliet adds Joliet file table
# --mbr-force-bootable does some magic
# -r (RockRidge file path format) is included by grub-mkrescue
# -iso-level 3 - because.

run() {
  cmd="${@}"
  echo "EXECUTING CMD: ${1}"
  shift
  echo "WITH ARGS:"
  while (( $# > 0 )); do
    echo "  ARG: ${1}"
    shift
  done

  "${cmd[@]}"
}

# todo: rewrite this with arrays. or python.
if [[ n"${preloadModules}" != n ]]; then
  grub-mkrescue ${grubAuthoringFlags} --modules="${preloadModules}" --product-name="${productName}" --product-version="${productVersion}" --mbr-force-bootable -joliet -iso-level 3 ${authoringFlags} -path-list pathlist -output $out/iso/$isoName
else
  grub-mkrescue ${grubAuthoringFlags} --product-name="${productName}" --product-version="${productVersion}" --mbr-force-bootable -joliet -iso-level 3 ${authoringFlags} -path-list pathlist -output $out/iso/$isoName
fi

if test -n "${compressorTemplate}"; then
  echo "Compressing image..."
  cmd=$(printf "${compressorTemplate}" $out/iso/$isoName)
  echo "Using compression: ${cmd}"
  eval $cmd
fi
# it is not actually writable, but makes it a bit more convenient, for example cp will be able to overwrite it on replace
chmod ug+w $out/iso/$isoName

mkdir -p $out/nix-support
echo $system > $out/nix-support/system

if test -n "${compressorTemplate}"; then
  echo "file iso $out/iso/$isoName.zst" >> $out/nix-support/hydra-build-products
else
  echo "file iso $out/iso/$isoName" >> $out/nix-support/hydra-build-products
fi

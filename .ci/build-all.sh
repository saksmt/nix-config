#!/usr/bin/env bash

cd "$(dirname "$(dirname "$(readlink -f "${0}")")")" || { echo "Failed to cd to repo root"; exit 1; }

_nix() {
  nix --extra-experimental-features 'nix-command flakes' "${@}"
  return $?
}

indent() {
  sed "s/^/${1}/g" >&${2}
}

build-hm() {
  config="${1}"
  echo "Building home-manager configuration named ${config}"
  shift
  _nix build --impure \
    .#homeConfigurations."${config}".activationPackage "${@}" \
    >  >(indent "  [${config}]> " 1) \
    2> >(indent "  [${config}]> " 2) || {
      echo "Failed to build home-manager configuration named ${config}";
      exit 1;
    }
}

build-nixos() {
  config="${1}"
  echo "Building nixos configuration named ${config}"
  shift
  _nix build --impure \
    .#nixosConfigurations."${config}".config.system.build.toplevel "${@}" \
    >  >(indent "  [${config}]> " 1) \
    2> >(indent "  [${config}]> " 2) || {
      echo "Failed to build nixos configuration named ${config}";
      exit 1;
    }
}

build-image() {
  config="${1}"
  echo "Building iso named ${config}"
  shift
  _nix build .#images."${config}" "${@}" \
    >  >(indent "  [${config}]> " 1) \
    2> >(indent "  [${config}]> " 2) || {
      echo "Failed to build iso named ${config}";
      exit 1;
    }
}

listAttrNames='x: builtins.concatStringsSep "\n" (builtins.attrNames x)'

get-hms() {
  _nix eval .#homeConfigurations --apply "${listAttrNames}" --raw 2>/dev/null
}

get-nixos-configs() {
  _nix eval .#nixosConfigurations --apply "${listAttrNames}" --raw 2>/dev/null
}

get-images() {
  _nix eval .#isoConfigurations.x86_64-linux --apply "${listAttrNames}" --raw 2>/dev/null
}

each() {
  while IFS= read -r line || [[ -n "$line" ]] ; do
    "${@}" "${line}" || exit 1
  done
}

export CI="true"

get-nixos-configs | each build-nixos || exit 1
get-hms | each build-hm || exit 1
get-images | each build-image || exit 1

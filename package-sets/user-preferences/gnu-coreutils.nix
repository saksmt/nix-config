{ pkgs, ... }: {
  module-for = [
    "hm"
    "darwin"
  ];
  install.packages = with pkgs; [
    coreutils-full
    wget
    curl
    indent
    findutils
    gnugrep
    gnutar
    gnused
    gawk
    zip
    unzip
    gnutls
  ];
}

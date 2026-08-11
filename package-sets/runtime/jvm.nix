{ pkgs, features, ... }:
with features;
let
  edition = if dev.jvm.isEnabled then "jdk" else "jre";
  headlessSuffix = if GUI.isEnabled then "" else "_headless";
  jvmVersion = 21;
  # for some reason exactly jre21_headless is missing, other combinations exist
  # todo: fixme!
  jvmPackageName = "${edition}${headlessSuffix}";
#  jvmPackageName = "${edition}${builtins.toString jvmVersion}${headlessSuffix}";
  jvmPackage = builtins.getAttr jvmPackageName pkgs;
in
{
  module-for = [
    "hm"
    "nixos"
  ];

  install.packages = [ jvmPackage ];
  programs.java.package = jvmPackage;
}

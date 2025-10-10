{
  config,
  pkgs,
  features,
  lib,
  ...
}:
with features;

lib.mkMerge [
  { module-for = [ "hm" ]; }

  (GUI.whenEnabled {
    fonts.packages =
      with pkgs;
      let
        iosevka-term = iosevka.override {
          privateBuildPlan = ''
            [buildPlans.IosevkaForTerm]
            family = "IosevkaForTerm"
            spacing = "term"
            serifs = "sans"
            exportGlyphNames = true

              [buildPlans.IosevkaForTerm.variants]
              inherits = "ss10"

              [buildPlans.IosevkaForTerm.ligations]
              inherits = "haskell"
              enables = [ "exeq", "html-comment", "slash-asterisk" ]
          '';
          set = "ForTerm";
        };
        nerd-patcher = writeShellApplication {
          name = "nerd-patch";
          runtimeInputs = [
            nerd-font-patcher
            fontforge
          ];
          text = ''
            read -r -a patchArgs <<< "''${FONT_PATCH_ARGS:--c}"
            sourceFont="''${1}"
            sourceFontDir="$(dirname "''${sourceFont}")"
            sourceFontFile="$(basename "''${sourceFont}")"
            targetName="''${sourceFontFile%.*}-nf.''${sourceFontFile##*.}"

            cd "''${sourceFontDir}"

            echo "Patching ''${sourceFontFile}, will write it as ''${targetName}" >&2
            nerd-font-patcher "''${patchArgs[@]}" "''${sourceFontFile}" || { echo "Failed patching. Args: ''${patchArgs[*]} ''${sourceFontFile}">&2; exit 1; }
            mv "''${sourceFontFile}" "''${targetName}"
          '';
        };
        nerdify =
          font:
          stdenvNoCC.mkDerivation {
            name = "${font.name}-nf";
            src = font;
            nativeBuildInputs = [ nerd-patcher ];
            buildPhase = ''
              export FONT_PATCH_ARGS="-cq --makegroups 4"
              # for some unholy unknown reason find -exec does not work here...
              find . -name '*.ttf' -o -name '*.otf' | xargs -P''${NIX_BUILD_CORES:-1} -n1 nerd-patch
            '';
            installPhase = "cp -a . $out";
          };
      in
      [
        ubuntu_font_family
        hasklig
        terminus_font
        terminus_font_ttf
        iosevka-term
        (nerdify iosevka-term)
      ];
    fonts.fontconfig.enable = true;
    fonts.fontconfig.defaultFonts.monospace = [ "Hasklig" ];
    fonts.fontconfig.defaultFonts.sansSerif = [ "Ubuntu" ];
    fonts.fontconfig.defaultFonts.serif = [ "Ubuntu" ];
  })
]

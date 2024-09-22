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
        nerdify =
          font:
          stdenvNoCC.mkDerivation {
            name = "${font.name}-nf";
            src = font;
            nativeBuildInputs = [ nerd-font-patcher ];
            buildPhase = ''
              find -name \*.ttf -o -name \*.otf -exec nerd-font-patcher -c {} \;
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

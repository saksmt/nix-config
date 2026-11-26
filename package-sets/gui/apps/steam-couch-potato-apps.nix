{
  config,
  lib,
  pkgs,
  ...
}:
{
  module-for = [ "hm" ];

  programs.steam.config = {
    enable = true;
    nonSteamApps = {
      "MPV" = lib.mkIf config.programs.mpv.enable {
        # why not directly use pkg? - that will drop all the scripts and configs
        # why not "mpv"? - that will potentially fail to resolve from inside modified env of steam
        target = pkgs.writeShellScriptBin "run-mpv" "mpv --idle --player-operation-mode=pseudo-gui";
        # generic seed so that swap to something other that mpv won't break anything
        seed = "media player";
        artwork = {
          # 460x215 in library
          header = pkgs.fetchurl {
            url = "https://cdn2.steamgriddb.com/grid/f385a77ff0efb9d48dc66cea023a86c9.png";
            name = "mpv-header.png";
            hash = "sha256-5LiOL1FxCqC7S0EzlTfpQ368UNvZFXkH05chQC48Qm4=";
          };
          # 600x900 in library
          cover = pkgs.fetchurl {
            url = "https://cdn2.steamgriddb.com/grid/766835a2ac87e88753b9c40fe22b7cc1.png";
            name = "mpv-cover.png";
            hash = "sha256-LhhCWIDdiJTEmC7A4HjdP2EokjTN7b2rvm2L54K9/Ng=";
          };
          # overlay on top of app page background
          logo = pkgs.fetchurl {
            url = "https://cdn2.steamgriddb.com/logo/0e48628f1bf338bc777db5ca98f07800.png";
            name = "mpv-logo.png";
            hash = "sha256-SLQOE88o8b2CeiLYo/IXDrm13VLBmHqocs6jTmqJqdQ=";
          };
          # library page background
          hero = pkgs.fetchurl {
            url = "https://cdn2.steamgriddb.com/hero/788ecdd13f033f8131eecd90ee59993e.png";
            name = "mpv-hero.png";
            hash = "sha256-i9G1HqZX7Pnh0FNKI0qZGqpq/a3XjS/Q0W7zcyvJ3iM=";
          };
          # taskbar, shortcuts, desktop icon. square
          icon = pkgs.fetchurl {
            url = "https://upload.wikimedia.org/wikipedia/commons/7/73/Mpv_logo_(official).png";
            name = "mpv-icon.png";
            hash = "sha256-ejB0PzFamZ1xWjsgS4wuWvSlOE4igCMzojVvoT0J2Hw=";
          };
        };

      };

      "Moonlight" = lib.mkIf config.programs.moonlight.enable {
        # why not directly use pkg? - that defeats the purpose of programs.moonlight.package and potential other modifications
        # why not "moonlight"? - that will potentially fail to resolve from inside modified env of steam
        target = pkgs.writeShellScriptBin "run-moonlight" "moonlight";
        seed = "game streaming client";
        artwork = {
          # 460x215 in library
          header = pkgs.fetchurl {
            url = "https://cdn2.steamgriddb.com/grid/5fe23c78c7e096fe45cd0729087fd0c8.png";
            name = "moonlight-header.png";
            hash = "sha256-FMspAaelCY+FszSlVi4lqhYSoAX8Rib8qIUanJoQ0xM=";
          };
          # 600x900 in library
          cover = pkgs.fetchurl {
            url = "https://cdn2.steamgriddb.com/grid/ae15d7f6722259ff481b3d4e85140e4e.png";
            name = "moonlight-cover.png";
            hash = "sha256-docIZRAVr4plmE1sbqVnrcc7/5Or8/u8owX44cMvi+M=";
          };
          # overlay on top of app page background
          logo = pkgs.fetchurl {
            url = "https://cdn2.steamgriddb.com/logo/99e4052bfd7190e6e3936a057ac3170b.png";
            name = "moonlight-logo.png";
            hash = "sha256-DIvPdsiVFELphzIxPubqb+HG7BaTJ6S9mQkwADngPs0=";
          };
          # library page background
          hero = pkgs.fetchurl {
            url = "https://cdn2.steamgriddb.com/hero/3f08773a0636312ef28c097a19fb314c.png";
            name = "moonlight-hero.png";
            hash = "sha256-+ozlr2pkjAUoAyOHIgGh+vbNeybNu5EZnhni1wpKL/Y=";
          };
          # taskbar, shortcuts, desktop icon. square
          icon =
            let
              built =
                pkgs.runCommand "convert-moonlight-icon-to-png"
                  {
                    buildInputs = [ pkgs.librsvg ];
                  }
                  ''
                    mkdir -p $out
                    rsvg-convert -w 512 -h 512 "${pkgs.moonlight-qt}/share/icons/hicolor/scalable/apps/moonlight.svg" -o $out/moonlight-logo.png
                  '';
            in
            "${built}/moonlight-logo.png";
        };
      };
    };
  };
}

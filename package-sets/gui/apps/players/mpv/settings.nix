{ pkgs, lib, ... }: {
  programs.mpv = {
    enable = true;
    scripts = [
      (pkgs.mpvScripts.uosc.overrideAttrs (prev: {
        version = "master";
        src = pkgs.fetchFromGitHub {
          owner = "saksmt";
          repo = "uosc";
          rev = "feature/programmatic-file-chooser";
          hash = "sha256-5C4gbSO1c0FPsViyA9JgEfqCOu8xEFHsrPv7z7uMr0Y=";
        };
      }))
      pkgs.mpvScripts.thumbfast
    ];

    uosc.menu = {
      fs = {
        title = "Open...";
        items = [
          {
            item = {
              title = "Home";
              value = [
                "script-message-to"
                "extra_uosc_menu"
                "open-file-menu"
                "~"
              ];
            };
          }
        ];
      };
    };

    config = {
      hwdec = "auto-safe";
      fs = "yes";
      keep-open = "yes";
      osc = "no";
      border = "no";
      input-default-bindings = "no";
    };
    scriptOpts = {
      uosc = {
        timeline_persistency = "paused";
        top_bar_persistency = "paused";
        top_bar = "always";
        controls = "menu,gap,subtitles,<has_many_audio>audio,<has_many_video>video,<has_many_edition>editions,<stream>stream-quality,gap,space,prev,items,next,gap,fullscreen";
        timeline_style = "bar";
        timeline_border = 1;
      };
      thumbfast = {
        network = "no";
        hwdec = "yes";
      };
    };
    bindings = {
      "MBTN_LEFT" = "ignore";
      "MBTN_LEFT_DBL" = "cycle fullscreen";
      "MBTN_RIGHT" = "script-message-to extra_uosc_menu open-menu main";
      "WHEEL_UP" = "add volume 2";
      "WHEEL_DOWN" = "add volume -2";

      "SPACE" = "cycle pause";
      "LEFT" = "script-binding staged_seek/step-back";
      "RIGHT" = "script-binding staged_seek/step-fwd";
      "ENTER" = "script-binding staged_seek/confirm-only";
      "KP_ENTER" = "script-binding staged_seek/confirm-only";
      "ESC" = "script-binding staged_seek/cancel-or-unfullscreen";
      "UP" = "script-message-to uosc flash-elements timeline,controls,top_bar";
      "DOWN" = "script-message-to uosc flash-elements timeline,controls,top_bar";

      # gamepad
      "a" = "script-binding staged_seek/confirm-or-pause";
      "b" = "script-binding staged_seek/cancel-seek";
      "y" = "script-message-to extra_uosc_menu open-menu fs";
      "x" = "script-message-to extra_uosc_menu open-menu main";

      "l" = "cycle sub";
      "r" = "cycle sub down";
      "L" = "cycle audio";
      "R" = "cycle audio down";

      "q" = "quit";
    };
  };
}

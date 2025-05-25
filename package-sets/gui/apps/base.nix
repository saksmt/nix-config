{
  features,
  pkgs,
  lib,
  ...
}:
with features;
lib.mkMerge [
  {
    module-for = [ "hm" ];
  }
  (GUI.whenEnabled {
    install.packages =
      with pkgs;
      [
        keepassxc
      ]
      ++ (lib.lists.optional (!work-ban.isEnabled) transmission-remote-gtk);

    catppuccin.kitty.enable = true;
    programs.kitty = {
      enable = true;
      font = {
        name = "IosevkaForTerm Nerd Font";
        size = if HiDPI.isEnabled then 19 else 14;
      };
      shellIntegration.enableZshIntegration = true;
      shellIntegration.mode = "no-rc no-cursor";

      /*themeFile = "Tango_Dark";
      settings = {
        background = "#2B2B2B";
        selection_foreground = "none";
        selection_background = "none";
        cursor_shape = "block";
      };*/
    };
    shells.zsh.rc-extra.bottom = ''
      function clip() {
        if [ -t 1 ]; then kitten clipboard -g; else kitten clipboard; fi;
      }
    '';
    programs.zsh.shellAliases.icat = "kitten icat";
    programs.zsh.shellAliases.ssh = "kitten ssh";

    programs.firefox = {
      enable = true;

      nativeMessagingHosts = [ pkgs.keepassxc ];
      /*languagePacks = [
        "en-US"
        "ru-RU"
      ];*/

      # https://mozilla.github.io/policy-templates/
      policies = {
        DisableAppUpdate = true;
        DisablePocket = true;
        DisableSetDesktopBackground = true;
        DontCheckDefaultBrowser = true;
        HardwareAcceleration = true;
        OfferToSaveLoginsDefault = false;
        RequestedLocales = [ "en-US" "ru-RU" ];

        # Potentially useful in future:
        /*AutoLaunchProtocolsFromOrigins = [
          {
            protocol = "telegram";
            allowed_origins = [ "https://t.me" ];
          }
        ];*/
        /*HttpAllowList = [ "http://some-test-domain" ];*/


      };

      profiles.default = {
        extensions = [];
        settings = {
          "browser.download.always_ask_before_handling_new_types" = true;
          "browser.download.useDownloadDir" = false;
          "browser.search.countryCode" = "RU";
          "browser.search.region" = "GE";
          # 0 - blank, 1 - default, 2 - last visited, 3 - restore
          "browser.startup.page" = 3;
          "browser.tabs.warnOnClose" = true;
          "devtools.theme" = "dark";
          "general.autoScroll" = true;
          "privacy.donottrackheader.enabled" = true;
          "reader.color_scheme" = "dark";
          "browser.display.use_system_colors" = true;
        };

        userChrome = ''
        @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

        #main-window {
            --toolbar-bgcolor: #31363b !important;
        }

        #sidebar-box #sidebar-header {
            visibility: collapse;
        }

        #sidebar-box ~ #sidebar-splitter {
            background-color: #31363b !important;
            border-color: #31363b !important;
            color: #31363b !important;
        }

        /* Fuck border radius */
        #main-window #urlbar,
        button,
        button:hover,
        input[type="reset"]:hover,
        input[type="reset"],
        input[type="button"]:hover,
        input[type="button"],
        input[type="submit"]:hover,
        input[type="submit"],
        toolbarbutton,
        toolbarbutton:hover,
        panel toolbarbutton.subviewbutton,
        panel toolbarbutton.subviewbutton:hover {
            border-radius: 0 !important;
        }

        #tabbrowser-tabs {
            visibility: collapse !important;
        }

        #main-window[privatebrowsingmode="temporary"] #TabsToolbar, #main-window[inFullscreen] #TabsToolbar {
            background-color: #11161b;
        }

        #navigator-toolbox > toolbar:not(#TabsToolbar):not(#toolbar-menubar), .browserContainer > findbar, #browser-bottombox, #toolbar-menubar {
            background-color: #31363b !important;
        }


        .findbar-button:hover {
            color: #ddd !important;
        }

        .findbar-button[checked="true"]:not(:hover) {
            color: white !important;
        }

        :root[uidensity="compact"] #nav-bar[brighttext] > #PanelUI-button {
            border-image-source: linear-gradient(transparent 4px, rgba(100%,100%,100%,.2) 4px, rgba(100%,100%,100%,.2) calc(100% - 4px), transparent calc(100% - 4px));
        }

        :root[uidensity="compact"] #PanelUI-button {
            margin-inline-start: 3px;
            border-inline-start: 1px solid;
            border-image: linear-gradient(transparent 4px, rgba(0,0,0,.1) 4px, rgba(0,0,0,.1) calc(100% - 4px), transparent calc(100% - 4px));
            border-image-source: linear-gradient(transparent 4px, rgba(0, 0, 0, 0.1) 4px, rgba(0, 0, 0, 0.1) calc(100% - 4px), transparent calc(100% - 4px));
            border-image-slice: 100%;
            border-image-slice: 1;
        }
        #main-window[titlepreface^="[1] "] #sidebar-box[sidebarcommand="_0ad88674-2b41-4cfb-99e3-e206c74a0076_-sidebar-action"] {
          visibility: collapse;
        }
        #sidebar-box[sidebarcommand="_0ad88674-2b41-4cfb-99e3-e206c74a0076_-sidebar-action"] #sidebar-header {
          visibility: collapse;
        }
        #toolbar-menubar[inactive="true"] + #TabsToolbar {
          visibility: collapse !important;
        }
        #main-window:not([customizing]):not([tabsintitlebar="true"]) #TabsToolbar {
          visibility: collapse;
        }
        #navigator-toolbox {
          margin-top: 1px;
        }
        #sidebar-box #sidebar-header {
          visibility: collapse;
        }
        '';
      };
    };

  })
]

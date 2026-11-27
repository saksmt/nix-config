{ nixos-hardware, feature-definitions, ... }:
rec {
  imports = [
    nixos-hardware.nixosModules.asus-zephyrus-gu603h
    nixos-hardware.nixosModules.asus-battery

    (
      { pkgs, ... }:
      {
        system.stateVersion = "24.05";

        users.users.smt.shell = pkgs.zsh;
        users.users.root.shell = pkgs.zsh;

        networking.hostId = "aff1aff1";

        programs.steam.package = pkgs.steam.override {
          # nvidia-offload hacks. would've been better to somehow get those
          # from config, but it is impossible as of now.
          #
          # imperfect: better way is to append those to launch options
          # of specific games to use battery better, also seems like hw encoding
          # may be better on mesa. But this solution is plain simpler usability-wise
          extraEnv = {
            __NV_PRIME_RENDER_OFFLOAD = "1";
            __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            __VK_LAYER_NV_optimus = "NVIDIA_only";
          };
        };

        environment.systemPackages = with pkgs; [
          asusctl
          supergfxctl
        ];

        systemd.packages = [
          pkgs.supergfxctl
          pkgs.asusctl
        ];
        services.udev.packages = [
          pkgs.supergfxctl
          pkgs.asusctl
        ];
        services.udev.extraRules = ''
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl", GROUP="users"
        '';
        services.dbus.packages = [
          pkgs.supergfxctl
          pkgs.asusctl
        ];
        systemd.services.supergfxd.wantedBy = [ "multi-user.target" ];
        boot.supportedFilesystems = [ "ntfs" ];
        boot.loader.grub.gfxmodeEfi = "1280x800";
        services.xserver.deviceSection = ''Option "RegistryDwords" "EnableBrightnessControl=1"'';
        boot.kernelParams = [
          "i915.enable_psr=0"
        ];
        boot.kernel.sysctl = {
          "vm.swappiness" = 20;
        };
        hardware.asus.battery = {
          chargeUpto = 60;
          enableChargeUptoScript = true;
        };
      }
    )
  ];

  users.users.smt = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "kvm"
      "adbusers"
      "input"
      "audio"
      "render"
    ];
  };
  home-manager.users.smt =
    { pkgs, ... }:
    {
      home.stateVersion = "24.05";
    };
  home-manager.users.potato = { pkgs, ... }: {
    home.stateVersion = "26.05";
  };

  networking.hostName = "smt-laptop";
  networking.hosts = {
    "127.0.0.1" = [ "smt-laptop" ];
  };

  environment.couch-potato = {
    prefer-vk-device = "10de:24a0";
    outputs = [
      {
        # shitty hdmi port, capped by bandwidth, prioritizing image quality
        name = "HDMI-A-1";
        hdr = true;
        resolution = "3840x2160";
        refresh-rate = 30;
        vrr = false;
      }
      # false to vrr, so that it is disabled system-wide in hyprland impl
      { name = "eDP-1"; hdr = true; vrr = false; }
    ];
  };

  installation = {
    unstables =
      {
        from,
        unstable,
        master,
        copy-of,
        ...
      }:
      {
        jetbrains.idea = from master;
        gemini-cli = from master;
        opencode = from master;
        opencode-desktop = from master;

        asusctl = from unstable;
        supergfxctl = from unstable;

        wrapOBS = from unstable;
        obs-studio-plugins = from unstable;

        unstable = copy-of unstable;
      };

    features = with feature-definitions; [
      GUI
      EFI
      HiDPI

      laptop

      gaming

      dev.all
      android
    ];

    package-sets = [
      "system"
      "system/fonts"
      "system/plymouth"
      "system/boot/grub"

      "system/couch-potato"

      "runtime/docker"
      "runtime/jvm"

      "cli"
      "dev"

      "gui/setup/base"
      "gui/setup/sddm"
      "gui/setup/xorg"

      "gui/apps/gaming"
    ];

    home-manager =
      let
        extraMpvPaths = [
          {
            item = {
              title = "Win-D";
              value = [
                "script-message-to"
                "uosc"
                "open-file-menu"
                "/mnt/win-d"
              ];
            };
          }
        ];
      in
      {
        enabled = true;

        # force management of zshrc and stuff through home-manager
        programs.zsh.enable = true;

        programs.git.enable = true; # force management of git config through home-manager
        programs.git.settings.user = {
          name = "Kirill Saksin";
          email = "smt@saksmt.dev";
        };

        per-user = {
          potato = {
            installation.package-sets = [
              "gui/apps/players-wayland"
              "gui/apps/steam-couch-potato-apps"
              "gui/window-managers/barebones/wayland"
            ];

            programs.mpv.uosc.menu.fs.items = extraMpvPaths;
          };
          smt = {
            installation.package-sets = [
              "gui/apps/dev"
              "gui/apps/players"
              "gui/apps/media-editing"
              "gui/apps/streaming"
              "gui/window-managers/awesome"
              "dev/ai"
            ];

            imports = [
              (
                {
                  pkgs,
                  jail,
                  lib,
                  host-config,
                  ...
                }:
                {
                  programs.mpv.uosc.menu.fs.items = extraMpvPaths;
                  opencode.agents = {
                    brainstorm = {
                      model = "opencode-go/deepseek-v4-pro";
                      reasoningEffort = "high";
                    };
                    spec = {
                      model = "opencode-go/deepseek-v4-pro";
                      reasoningEffort = "high";
                    };
                    orchestrate = {
                      model = "opencode-go/glm-5.3-flash";
                      reasoningEffort = "low";
                    };
                    implementer = {
                      model = "opencode-go/mimo-v2.6-pro";
                    };
                    implementer-flash = {
                      model = "opencode-go/mimo-v2.6-flash";
                    };
                    reviewer = {
                      model = "opencode-go/glm-5.3";
                      reasoningEffort = "high";
                    };
                    explore = {
                      model = "opencode-go/glm-5.3-flash";
                      reasoningEffort = "low";
                    };
                  };
                  opencode.plugins.octto.settings = {
                    agents = {
                      probe.model = "opencode/big-pickle";
                      bootstrapper.model = "opencode/big-pickle";
                    };
                  };
                  opencode.plugins.notifier.settings = {
                    command = {
                      enabled = true;
                      path = pkgs.writeShellScript "ntfy-opencode" ''
                        project="$1"
                        event="$2"
                        session="$3"
                        agent="$4"

                        ntfyUser=$(< ~/.secrets/ntfy/opencode.user)
                        ntfyPassword=$(< ~/.secrets/ntfy/opencode.password)
                        ntfyHost=$(< ~/.secrets/home-server-host)

                        title="OpenCode [$project]"
                        icon="https://static.$ntfyHost/opencode-logo-dark.png"
                        message=
                        priority=
                        tags=

                        case "$event" in
                          permission )
                            tags=unlock
                            priority=high
                            if [[ n"$agent" != n ]]; then
                              message="$agent requests permission in $session"
                            else
                              message="Permission request in $session"
                            fi
                            ;;
                          complete|subagent_complete )
                            tags=heavy_check_mark,hourglass
                            priority=default
                            if [[ n"$agent" != n ]]; then
                              message="$agent completed in $session"
                            else
                              message="$session: completed"
                            fi
                            ;;
                          error )
                            tags=warning
                            priority=high
                            if [[ n"$agent" != n ]]; then
                              message="$agent failed in $session"
                            else
                              message="$session: failed"
                            fi
                            ;;
                          question )
                            tags=question
                            priority=high
                            if [[ n"$agent" != n ]]; then
                              message="$agent has a question for you about $session"
                            else
                              message="There is a question in $session"
                            fi
                            ;;
                          plan_exit )
                            tags=memo,heavy_check_mark
                            priority=high
                            if [[ n"$agent" != n ]]; then
                              message="$agent has completed a plan for $session"
                            else
                              message="Plan for $session is complete"
                            fi
                            ;;
                          * )
                            tags=question
                            priority=high
                            message="$event happened in $session (agent=$agent)"
                        esac

                        curl \
                          -H "Authorization: Basic $(echo -n "$ntfyUser:$ntfyPassword" | base64)" \
                          -H "Title: $title" \
                          -H "Icon: $icon" \
                          -H "Tags: $tags" \
                          -H "Priority: $priority" \
                          -d "$message" \
                          https://ntfy."$ntfyHost"/user_app_opencode

                      '';
                      args = [
                        "{projectName}"
                        "{event}"
                        "{sessionTitle}"
                        "{agentName}"
                      ];
                      minDuration = 15;
                    };

                    events = {
                      user_cancelled = false;
                      session_started = false;
                      user_message = false;
                      client_connected = false;
                    };
                  };
                }
              )
            ];
          };
        };
        installation = {
          package-sets = [
            "gui/apps/base"

            "gui/apps/im"
            # "gui/apps/gaming" it should've been here, but alas...

            "gui/apps/game-streaming"

            "gui/themes"

            "user-preferences"
          ];
          features = installation.features;
        };
      };
  };
}

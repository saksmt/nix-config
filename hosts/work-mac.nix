{ feature-definitions, ... }:
rec {
  imports = [
    (
      { pkgs, ... }:
      {
        system.stateVersion = 7;
        programs.zsh.enable = true;
        homebrew.enable = true;
        homebrew.casks = [ "hammerspoon" ];

        system.primaryUser = "Kirill.Saksin";
      }
    )
  ];

  home-manager.users."Kirill.Saksin" =
    { pkgs, ... }:
    {
      home.stateVersion = "26.05";
    };

  networking.hostName = "LMCWY27DP";

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

        rift-wm = from master;
        keepassxc = from unstable;

        sbt = from unstable;

        unstable = copy-of unstable;
      };

    features = with feature-definitions; [
      GUI

      laptop

      work
      work-ban

      dev.scala
      dev.jvm-other
      dev.nix
      dev.k8s

      HiDPI
    ];

    package-sets = [
      "system/fonts"
    ];

    home-manager = {
      enabled = true;

      # force management of zshrc and stuff through home-manager
      programs.zsh.enable = true;
      programs.zsh.shellAliases.ls = "ls --color";

      home.file."Library/KeyBindings/DefaultKeyBinding.dict".text = ''
        {
          "\\UF729" = "moveToBeginningOfLine:";
          "\\UF72B" = "moveToEndOfLine:";
        }
      '';
      home.file.".hammerspoon/init.lua".text = ''
        local function switchInputMethod()
          local layouts = hs.keycodes.layouts()
          local methods = hs.keycodes.methods()

          if (#layouts + #methods) <= 1 then return end

          local inputs = {}
          for _, name in ipairs(layouts) do table.insert(inputs, { name = name, isMethod = false }) end
          for _, name in ipairs(methods) do table.insert(inputs, { name = name, isMethod = true }) end

          local currentLayout = hs.keycodes.currentLayout()
          local currentMethod = hs.keycodes.currentMethod()

          for i, input in ipairs(inputs) do
            if currentLayout == input.name or currentMethod == input.name then
              local nextInput = inputs[(i % #inputs) + 1]

              if nextInput.isMethod then
                hs.keycodes.setMethod(nextInput.name)
              else
                hs.keycodes.setLayout(nextInput.name)
              end

              return
            end
          end
        end

        local modifierIsActive = false
        local cancelNextModifier = false

        local shiftAltTap = hs.eventtap.new({
          hs.eventtap.event.types.flagsChanged,
          hs.eventtap.event.types.keyDown
        }, function (event)
          local eventType = event:getType()

          if eventType == hs.eventtap.event.types.keyDown then
            cancelNextModifier = true
            return false
          end

          local flags = event:getFlags()
          local isShiftAltOnly = flags.shift and flags.alt and not flags.cmd and not flags.ctrl

          if isShiftAltOnly then
            modifierIsActive = true
            cancelNextModifier = false
          elseif modifierIsActive then
            if not cancelNextModifier and not flags.shift and not flags.alt then
              switchInputMethod()
            end

            if not flags.shift and not flags.alt then
              modifierIsActive = false
            end
          end

          return false
        end)

        shiftAltTap:start()
      '';

      programs.git.enable = true; # force management of git config through home-manager
      programs.git.settings.user = {
        name = "Kirill Saksin";
        email = "kirill.saksin@ringcentral.com";
      };

      services.colima.enable = true;
      services.colima.profiles.default = {
        isActive = true;
        isService = true;
        setDockerHost = true;
        settings = {
          cpu = 2;
          disk = 100;
          memory = 2;
          arch = "aarch64";
          runtime = "docker";
          hostname = "colima";
          vmType = "vz";
          mountInotify = true;
          network.address = true;
        };
      };

      installation = {
        package-sets = [
          "runtime/jvm"

          "cli"

          "gui/window-managers/macos/rift"

          "gui/apps/base"
          "gui/apps/dev"

          "gui/apps/players"

          "user-preferences"
          "user-preferences/gnu-coreutils"

          "dev"
          "dev/ai"
        ];
        features = installation.features;
      };

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
            home.sessionVariables.TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/var/run/docker.sock";
            shells.zsh.rc-extra.bottom = ''
              export TESTCONTAINERS_HOST_OVERRIDE=$(colima ls -j | jq -r '.address')
            '';

            install.packages = [ pkgs.docker-client ];
            opencode.plugins.octto.settings = {
              agents = {
                probe.model = "opencode/big-pickle";
                bootstrapper.model = "opencode/big-pickle";
              };
            };
          }
        )
      ];
    };
  };
}

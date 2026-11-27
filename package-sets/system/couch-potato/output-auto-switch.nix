{
  config,
  pkgs,
  ...
}:
let
  outputs = config.environment.couch-potato.outputs;
  userName = config.environment.couch-potato.user.name;
  nvl = a: fallback: if a == null then fallback else builtins.toString a;
  outputsTsv = builtins.concatStringsSep "\n" (
    builtins.map (
      output:
      builtins.concatStringsSep "\t" [
        output.name
        (nvl output.resolution "AUTO")
        (nvl output.refresh-rate "AUTO")
      ]
    ) outputs
  );
  syncModesScript = pkgs.writeShellApplication {
    name = "gamescope-output-sync";

    derivationArgs = {
      pname = "gamescope-output-sync";
      meta = {
        name = "gamescope-output-sync";
      };
    };

    runtimeInputs = [
      pkgs.util-linux
      pkgs.drm_info
      pkgs.jq
    ];

    text = ''
      now="[$(date)]"
      log="$(ls -d ~${userName})/.output-switch-log"

      log() {
        echo "''${@}" >> "$log"
      }
      log-n() {
        echo -n "''${@}" >> "$log"
      }

      log "$now ================"

      targetOutput=
      targetResolution=
      targetRefreshRate=

      IFS=$'\t'
      while read -r name resolution refreshRate; do
        log-n "considering $name"
        if [[ "$(cat /sys/class/drm/*-"$name"/status 2>/dev/null)" == "connected" ]]; then
          log " - connected"
          targetOutput="''${name}"
          targetResolution="''${resolution}"
          targetRefreshRate="''${refreshRate}"
          break
        fi
        log " - not connected"
      done <<< '${outputsTsv}'

      if [[ n"''${targetOutput}" == n ]]; then
        log "no output chosen"
        exit 0
      fi

      log "chosen output: $targetOutput"
      log "requested resolution: $targetResolution"
      log "requested refresh rate: $targetRefreshRate"

      if [[ "''${targetResolution}" == "AUTO" ]] || [[ "''${targetRefreshRate}" == "AUTO" ]]; then
        connectorId="$(head -n1 /sys/class/drm/*-"$targetOutput"/connector_id)"
        IFS=$'\t'
        read -r resolution refresh <<< "$(drm_info -j | \
          jq -r \
            --arg connectorId "''${connectorId}" \
            --arg requestedResolution "''${targetResolution}" \
            --arg requestedRefreshRate "''${targetRefreshRate}" \
            '
            [ .[].connectors[] | select(.id == ($connectorId | tonumber)) | .modes[] ] as $modes
            | ([ $modes[] | select("\(.hdisplay)x\(.vdisplay)" == $requestedResolution or $requestedResolution == "AUTO") ]) as $fittingByResolution
            | ([ $modes[] | select("\(.vrefresh)" == $requestedRefreshRate or $requestedRefreshRate == "AUTO") ]) as $fittingByRefreshRate
            | ($fittingByResolution - ($fittingByResolution - $fittingByRefreshRate)) as $fittingModes
            | $fittingModes[0]
            | if . == null then "" else "\(.hdisplay)x\(.vdisplay)\t\(.vrefresh)" end
            ')"

        if [[ n"''${resolution}" == n ]] || [[ n"''${refresh}" == n ]]; then
          log "could not resolve resolution and refresh rate to mode"
          exit 1
        fi

        targetResolution="''${resolution}"
        targetRefreshRate="''${refresh}"

        log "resolved resolution: $resolution"
        log "resolved refresh rate: $refresh"
      fi

      POTATO_UID=$(id -u "${userName}")
      RUNTIME_DIR="/run/user/$POTATO_UID"
      CFG_DIR="$(ls -d ~${userName})/.config/gamescope"
      if [[ "$targetResolution" =~ ^([0-9]+)x([0-9]+) ]]; then
        mkdir -p "$CFG_DIR"
        # Format expected by gamescope modes.cfg: <connector> <width> <height> <refresh>
        futureConfig=$(mktemp)
        echo "''${targetOutput}:''${targetResolution}@$targetRefreshRate" > "$futureConfig"
        hasChanges=n

        if ! cmp -s "$futureConfig" "$CFG_DIR/modes.cfg"; then
          log "modes on disk are different: overwriting"
          hasChanges=y
          mv "$futureConfig" "$CFG_DIR/modes.cfg"
          chown -R ${userName}:users "$CFG_DIR"
        else
          log "modes on disk are the same"
        fi

        rm -f "$futureConfig"

        # Notify live gamescope instance if potato session is currently running and there are changes in mode file
        if [ -d "$RUNTIME_DIR" ] && [[ "$hasChanges" == "y" ]]; then
          log "pinging gamescope daemon"
          {
          runuser -u ${userName} ${pkgs.gamescope}/bin/gamescopectl backend_set_dirty 2>&1 || true
          } >> "$log"
        fi
      else
        log "could not parse resolution"
      fi
      log "done"
      log "============== $now"
    '';
  };
  # Run the exact same mode detection before gamescope starts so initial boot matches too
  preStartSync = pkgs.writeShellScriptBin "gamescope" ''
    log="$(ls -d ~${userName})/.gamescope-pre-start-log"
    echo "identifying outputs" >> "$log"
    ${syncModesScript}/bin/gamescope-output-sync
    MODE_LINE=$(cat "$(ls -d ~${userName})/.config/gamescope/modes.cfg" 2>/dev/null)
    echo "got modeline: $MODE_LINE" >> "$log"
    EXTRA_ARGS=()
    if [[ "$MODE_LINE" =~ ^[A-Za-z0-9-]+:([0-9]+)x([0-9]+)@([0-9]+) ]]; then
      w="''${BASH_REMATCH[1]}"
      h="''${BASH_REMATCH[2]}"
      r="''${BASH_REMATCH[3]}"
      EXTRA_ARGS+=("-W" "''${w}" "-w" "''${w}" "-H" "''${h}" "-h" "''${h}" "-r" "''${r}")
    fi
    echo "starting gamescope:" exec ${pkgs.gamescope}/bin/gamescope "''${EXTRA_ARGS[@]}" "$@" >> "$log"
    exec ${pkgs.gamescope}/bin/gamescope "''${EXTRA_ARGS[@]}" "$@"
  '';
in
{
  # 1. Trigger mode sync automatically on any DRM display hotplug event
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", ACTION=="change", RUN+="${syncModesScript}/bin/gamescope-output-sync"
    SUBSYSTEM=="pci", ATTR{class}=="0x040300", ATTR{power/control}="on"
  '';

  # Why this instead of package override? This is local to gamescope session, override to package will override each usage of that package
  programs.steam.gamescopeSession.env.PATH = "${preStartSync}/bin:\${PATH}";
}

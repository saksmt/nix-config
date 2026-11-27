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
        (builtins.toString output.vrr)
        (builtins.toString output.hdr)
      ]
    ) outputs
  );
  getPreferredModeScript = pkgs.writeShellApplication {
    name = "get-preferred-output-mode";

    derivationArgs = {
      pname = "get-preferred-output-mode";
      meta = {
        name = "get-preferred-output-mode";
      };
    };

    runtimeInputs = [
      pkgs.util-linux
      pkgs.drm_info
      pkgs.jq
    ];

    text = ''
      outputModeOutput="''${1}"

      targetOutput=
      targetResolution=
      targetRefreshRate=
      vrr=
      hdr=

      IFS=$'\t'
      while read -r name resolution refreshRate enableVrr enableHdr; do
        echo -n "considering $name"
        if [[ "$(cat /sys/class/drm/*-"$name"/status 2>/dev/null)" == "connected" ]]; then
          echo " - connected"
          targetOutput="''${name}"
          targetResolution="''${resolution}"
          targetRefreshRate="''${refreshRate}"
          vrr="''${enableVrr}"
          hdr="''${enableHdr}"
          break
        fi
        echo " - not connected"
      done <<< '${outputsTsv}'

      if [[ n"''${targetOutput}" == n ]]; then
        echo "no output chosen" >&2
        exit 0
      fi

      echo "chosen output: $targetOutput"
      echo "requested resolution: $targetResolution"
      echo "requested refresh rate: $targetRefreshRate"

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
          echo "could not resolve resolution and refresh rate to mode" >&2
          exit 1
        fi

        targetResolution="''${resolution}"
        targetRefreshRate="''${refresh}"

        echo "resolved resolution: $resolution"
        echo "resolved refresh rate: $refresh"
      fi

      if [[ "$targetResolution" =~ ^([0-9]+)x([0-9]+) ]]; then
        w="''${BASH_REMATCH[1]}"
        h="''${BASH_REMATCH[2]}"
        {
          echo "$targetOutput"
          echo "$w"
          echo "$h"
          echo "$targetRefreshRate"
          echo "$vrr"
          echo "$hdr"
        } | tr '\n' '\t' > "''${outputModeOutput}"
      else
        echo "could not parse resolution" >&2
      fi
      echo "done"
    '';
  };
  # Run the exact same mode detection before gamescope starts so initial boot matches too
  preStartSync = pkgs.writeShellScriptBin "gamescope" ''
    if [[ -z "''${_IN_SYSTEMD_CAT:-}" ]]; then
      exec env _IN_SYSTEMD_CAT=1 ${pkgs.systemd}/bin/systemd-cat -t gamescope-session-pre-start "$0" "''${@}"
    fi
    unset _IN_SYSTEMD_CAT

    if [[ n"''${GAMESCOPE_BIN:-}" == n ]]; then
      echo "GAMESCOPE_BIN unset, don't know what to run, exiting" >&2
      exit 1
    fi

    echo "identifying outputs"
    outputFile="$(mktemp)"
    systemd-cat ${getPreferredModeScript}/bin/get-preferred-output-mode "$outputFile"
    EXTRA_ARGS=()
    if [[ -s "$outputFile" ]]; then
      IFS=$'\t'
      read -r output w h refreshRate vrr hdr < "$outputFile"

      EXTRA_ARGS+=("-W" "$w" "-H" "$h" "-r" "$refreshRate")

      if [[ "$vrr" == "true" ]]; then
        EXTRA_ARGS+=("--adaptive-sync")
      fi

      if [[ "$hdr" == "true" ]]; then
        EXTRA_ARGS+=("--hdr-enabled" "--hdr-debug-force-output")
      fi
    fi
    rm -f "$outputFile"

    echo "starting gamescope:" exec ${pkgs.gamescope}/bin/gamescope "''${EXTRA_ARGS[@]}" "$@"
    exec systemd-cat -t gamescope-session $GAMESCOPE_BIN "''${EXTRA_ARGS[@]}" "$@"
  '';
in
{
  # Why this instead of package override? This is local to gamescope session, override to package will override each usage of that package
  programs.steam.gamescopeSession.env.PATH = "${preStartSync}/bin:\${PATH}";
}

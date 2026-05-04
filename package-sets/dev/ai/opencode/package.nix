{
  pkgs,
  features,
  lib,
  ...
}:
with features;
{
  module-for = [
    "hm"
  ];

  install.packages =
    with pkgs;
    lib.lists.optionals dev.common.isEnabled (
      let
        opencodeConfd = "~/.config/opencode/conf.d";
        # using ".generated" suffix to avoid accidentally overwriting user configuration
        # configuration is setup via hm through symlink - that will warn about overwriting
        # on install
        opencodeConfigFile = "~/.config/opencode/opencode.generated.json";
        withOpencodeConfd =
          packages-to-wrap:
          runCommandNoCC "opencode-configured" { } ''
            mkdir -p $out/bin

            { ${
              builtins.concatStringsSep "; " (builtins.map (pkg: "readlink -f ${pkg}/bin/* ") packages-to-wrap)
            }
            } | while IFS= read -r app; do
              bin="$out/bin/''${app##*/}"
              cat <<EOF | sed -E 's/\s+[|](\ |$)//g' > $bin
                | #!/usr/bin/env bash
                |
                | ${json-confd}/bin/json-confd ${opencodeConfd} ${opencodeConfigFile} \\
                |   || exit 1
                | # forwarding to the original app
                |
                | # Disabling project-local config loading for security reasons by default
                | # Explicit trust is required
                | # Reason: config may contain ANY commands and ANY javascript plugins!
                |
                | disable_project_conf="true"
                | if [[ "\$TRUST_PROJECT" == "true" || "\$OPENCODE_DISABLE_PROJECT_CONFIG" == "false" ]]; then
                |   disable_project_conf="false"
                | fi
                |
                | export OPENCODE_DISABLE_PROJECT_CONFIG="\$disable_project_conf"
                |
                | exec $app "\''${@}"
            EOF
              chmod +x $bin

            done
          '';
      in
      [
        (withOpencodeConfd (
          [
            opencode
          ]
          ++ (lib.lists.optionals GUI.isEnabled [
            opencode-desktop
          ])
        ))
      ]

    );
}

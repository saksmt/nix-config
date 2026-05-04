{ writeShellApplication, jq }:

let
  jqDeepMerge = ./json-confd.jq;
in
writeShellApplication {
  name = "json-confd";

  runtimeInputs = [ jq ];

  text = ''

    INPUT="''${1}"
    OUTPUT="''${2}"

    if ! [[ -d "$INPUT" ]]; then
      echo "json-confd: $INPUT directory does not exist, nothing to do"
      exit 0
    fi

    OUTPUT_DIR="$(dirname "$OUTPUT")"

    if [[ ! -d "$OUTPUT_DIR" ]]; then
      echo "json-confd: $OUTPUT_DIR directory does not exist (parent for output file)!"
      exit 1
    fi

    get-content() {
      while IFS= read -r file; do
        if [[ -x "$file" ]]; then
          "$file"
        else
          cat "$file"
        fi
      done
    }

    find "''${INPUT}" \( -type f -or -type l \) -name \*.json \
      | sort \
      | get-content \
      | jq -n -f ${jqDeepMerge} \
      > "''${OUTPUT}" \
      || exit 1

  '';
}

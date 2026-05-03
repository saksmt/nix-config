{ writeShellApplication, jq, systemd, mcp-proxy }:

writeShellApplication {
  name = "mcp-wrapper";

  # We need jq to parse the JSON-RPC handshake, and systemd for journald logging
  # mcp-proxy included as a bonus to neatly wrap SSE/HTTPStream endpoints
  runtimeInputs = [ jq systemd mcp-proxy ];

  text = ''
    if [ "$#" -lt 2 ]; then
      echo "Usage: mcp-wrapper <server-name> <command> [args...]" >&2
      exit 1
    fi

    NAME="$1"
    shift

    log.info() {
      systemd-cat -t "mcp-$NAME" -p info
    }

    log.error() {
      systemd-cat -t "mcp-$NAME" -p err
    }

    # Disabled by default unless explicitly set to true/1
    IS_ENABLED="''${ENABLED:-false}"

    if [[ "$IS_ENABLED" != "true" && "$IS_ENABLED" != "1" ]]; then
      # MCP tool names should ideally be alphanumeric with underscores
      SAFE_NAME=$(echo "$NAME" | tr '-' '_')

      echo "''${NAME} mcp server disabled via 'ENABLED=''${ENABLED}'. Starting mock MCP server to gracefully ghost the client." | log.info

      # Read JSON-RPC requests from stdin line-by-line
      while IFS= read -r line; do
        # Skip empty lines or non-JSON to prevent jq crashes
        if ! printf "%s" "$line" | jq -e . >/dev/null 2>&1; then
          continue
        fi

        # Extract the request ID and Method
        id=$(printf "%s" "$line" | jq -c '.id // empty')
        method=$(printf "%s" "$line" | jq -r '.method // empty')

        if [[ -n "$id" ]]; then
          if [[ "$method" == "initialize" ]]; then
            # We must declare that we support tools so the client asks for them
            printf '{"jsonrpc":"2.0","id":%s,"result":{"protocolVersion":"2024-11-05","capabilities":{"tools":{}},"serverInfo":{"name":"%s-disabled","version":"0.0.0"}}}\n' "$id" "$NAME"

          elif [[ "$method" == "tools/list" ]]; then
            # Expose a single descriptive tool
            printf '{"jsonrpc":"2.0","id":%s,"result":{"tools":[{"name":"%s_disabled_info","description":"This MCP server is currently disabled. Call this tool to learn how to enable it.","inputSchema":{"type":"object","properties":{}}}]}}\n' "$id" "$SAFE_NAME"

          elif [[ "$method" == "tools/call" ]]; then
            # If the LLM actually tries to call it, tell it what to do
            printf '{"jsonrpc":"2.0","id":%s,"result":{"content":[{"type":"text","text":"The %s MCP server is currently disabled in this project context. To enable it, the developer must set the corresponding ENABLE_ env var (e.g., in .envrc) and restart the CLI session."}],"isError":false}}\n' "$id" "$NAME"

          else
            # Graceful fallback for everything else
            printf '{"jsonrpc":"2.0","id":%s,"result":{"resources":[],"prompts":[]}}\n' "$id"
          fi
        fi
      done

      exit 0
    fi

    echo "Starting ''${NAME} MCP server: $*" | log.info

    # Execute the actual server.
    # Redirect stderr to journald. Keep stdout untouched for the MCP client.
    "$@" 2> >(log.error)
  '';
}

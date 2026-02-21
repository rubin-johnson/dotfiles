#!/usr/bin/env bash
# Block failing claude.ai remote MCP servers that attempt connection on every startup
# but lack OAuth tokens. These are server-side Anthropic-provided connectors that
# can only be blocked via the enterprise managed-settings path.
set -euo pipefail

MANAGED_SETTINGS="/etc/claude-code/managed-settings.json"

sudo mkdir -p /etc/claude-code
sudo tee "$MANAGED_SETTINGS" > /dev/null << 'EOF'
{
  "deniedMcpServers": [
    { "serverUrl": "https://mcp-proxy.anthropic.com/v1/mcp/mcpsrv_01NTDKyCQ2557s2pCzBbBUuR" },
    { "serverUrl": "https://mcp-proxy.anthropic.com/v1/mcp/mcpsrv_01NJfwvBYFHUKhUuAzTKB5UM" },
    { "serverUrl": "https://mcp-proxy.anthropic.com/v1/mcp/mcpsrv_0163jnk1WuQisDNR1CCaGj8p" },
    { "serverUrl": "https://mcp-proxy.anthropic.com/v1/mcp/mcpsrv_01P4yjYQAT9tvXRNfMtE5aoR" }
  ]
}
EOF

echo "Claude Code managed settings written to $MANAGED_SETTINGS"

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
    { "serverName": "claude.ai EVO" },
    { "serverName": "claude.ai Notion" },
    { "serverName": "claude.ai Atlassian" }
  ]
}
EOF

echo "Claude Code managed settings written to $MANAGED_SETTINGS"

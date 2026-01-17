#!/bin/bash
set -e

echo "🚀 Clawdbot Coolify Bootstrap"
echo "=============================="

# Create config directory
mkdir -p /home/node/.clawdbot/logs

# Generate clawdbot.json from environment variables
echo "📝 Generating clawdbot.json from environment variables..."

cat > /home/node/.clawdbot/clawdbot.json <<EOF
{
  "gateway": {
    "port": 18789,
    "auth": {
      "mode": "token",
      "token": "$CLAWDBOT_GATEWAY_TOKEN"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "$TELEGRAM_BOT_TOKEN",
      "dm": {
        "policy": "allowlist",
        "allowFrom": [
          "$ALLEN_TELEGRAM_ID",
          "$KIM_TELEGRAM_ID",
          "$SUE_TELEGRAM_ID"
        ]
      }
    }
  },
  "agents": {
    "router": {
      "mode": "static",
      "rules": [
        { "from": "telegram:$ALLEN_TELEGRAM_ID", "agent": "allen" },
        { "from": "telegram:$KIM_TELEGRAM_ID", "agent": "kim" },
        { "from": "telegram:$SUE_TELEGRAM_ID", "agent": "sue" }
      ]
    },
    "defaults": {
      "model": "claude-sonnet-4.5",
      "provider": "anthropic"
    },
    "list": [
      {
        "id": "allen",
        "displayName": "Allen's AI",
        "workspace": "/home/node/clawd-allen",
        "sandbox": { "mode": "off" },
        "systemPrompt": "You are Allen's personal AI assistant with full access to tools and commands."
      },
      {
        "id": "kim",
        "displayName": "Kim's AI",
        "workspace": "/home/node/clawd-kim",
        "sandbox": {
          "mode": "all",
          "scope": "agent",
          "workspaceAccess": "none"
        },
        "tools": {
          "allow": [
            "sessions_list",
            "sessions_history",
            "sessions_send",
            "web_search",
            "web_fetch"
          ],
          "deny": [
            "read",
            "write",
            "edit",
            "exec",
            "process",
            "browser",
            "elevated"
          ]
        },
        "systemPrompt": "You are Kim's AI assistant. You can chat, answer questions, and search the web. You don't have access to files or system commands."
      },
      {
        "id": "sue",
        "displayName": "Sue's AI",
        "workspace": "/home/node/clawd-sue",
        "sandbox": {
          "mode": "all",
          "scope": "agent",
          "workspaceAccess": "none"
        },
        "tools": {
          "allow": [
            "sessions_list",
            "sessions_history",
            "sessions_send",
            "web_search",
            "web_fetch"
          ],
          "deny": [
            "read",
            "write",
            "edit",
            "exec",
            "process",
            "browser",
            "elevated"
          ]
        },
        "systemPrompt": "You are Sue's AI assistant. You can chat, answer questions, and search the web. You don't have access to files or system commands."
      }
    ]
  },
  "logging": {
    "level": "info",
    "file": "/home/node/.clawdbot/logs/clawdbot.log"
  }
}
EOF

echo "✅ Configuration generated at /home/node/.clawdbot/clawdbot.json"

# Create workspace directories
echo "📁 Creating workspace directories..."
mkdir -p /home/node/clawd-allen
mkdir -p /home/node/clawd-kim
mkdir -p /home/node/clawd-sue

echo "✅ Workspaces created"

# Verify required environment variables
echo "🔍 Checking required environment variables..."
MISSING_VARS=()

[ -z "$TELEGRAM_BOT_TOKEN" ] && MISSING_VARS+=("TELEGRAM_BOT_TOKEN")
[ -z "$ANTHROPIC_API_KEY" ] && MISSING_VARS+=("ANTHROPIC_API_KEY")
[ -z "$CLAWDBOT_GATEWAY_TOKEN" ] && MISSING_VARS+=("CLAWDBOT_GATEWAY_TOKEN")
[ -z "$ALLEN_TELEGRAM_ID" ] && MISSING_VARS+=("ALLEN_TELEGRAM_ID")
[ -z "$KIM_TELEGRAM_ID" ] && MISSING_VARS+=("KIM_TELEGRAM_ID")
[ -z "$SUE_TELEGRAM_ID" ] && MISSING_VARS+=("SUE_TELEGRAM_ID")

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
  echo "❌ Missing required environment variables:"
  for var in "${MISSING_VARS[@]}"; do
    echo "   - $var"
  done
  exit 1
fi

echo "✅ All required environment variables are set"

echo ""
echo "=============================="
echo "🎉 Bootstrap complete!"
echo "=============================="
echo ""
echo "Starting Clawdbot Gateway..."
echo ""

# Now run the actual gateway command
exec "$@"

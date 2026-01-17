# Coolify Deployment Guide for Family Clawdbot

## Project Info
- **Coolify URL**: https://coolify.allenlinli.com
- **Application Domain**: https://clawbot.allenlinli.com
- **GitHub Repo**: https://github.com/allenlinli/clawdbot
- **VPS**: 72.60.28.11

---

## Step 1: Environment Variables

In Coolify environment variables page, add these:

### Required Secrets (Get from Bitwarden)

```bash
# Telegram Bot Token (from @BotFather)
TELEGRAM_BOT_TOKEN=your-token-from-botfather

# Anthropic API Key (your Claude Code subscription)
ANTHROPIC_API_KEY=sk-ant-...

# Gateway Authentication Token (generate: openssl rand -base64 32)
CLAWDBOT_GATEWAY_TOKEN=your-generated-token

# Telegram User IDs (get from @userinfobot)
ALLEN_TELEGRAM_ID=123456789
KIM_TELEGRAM_ID=987654321
SUE_TELEGRAM_ID=555666777
```

### Clawdbot Configuration (copy these exactly)

```bash
# Gateway Settings
CLAWDBOT_GATEWAY_PORT=18789
CLAWDBOT_GATEWAY_BIND=lan
CLAWDBOT_BRIDGE_PORT=18790

# Config directories (inside container)
CLAWDBOT_CONFIG_DIR=/home/node/.clawdbot
CLAWDBOT_WORKSPACE_DIR=/home/node/clawd

# Home directory
HOME=/home/node

# Terminal settings
TERM=xterm-256color

# Node environment
NODE_ENV=production
```

### Agent Configuration (JSON in single env var)

Create an environment variable called `CLAWDBOT_CONFIG_JSON` with this value:

```json
{
  "gateway": {
    "port": 18789,
    "auth": {
      "mode": "token",
      "token": "${CLAWDBOT_GATEWAY_TOKEN}"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "${TELEGRAM_BOT_TOKEN}",
      "dm": {
        "policy": "allowlist",
        "allowFrom": [
          "${ALLEN_TELEGRAM_ID}",
          "${KIM_TELEGRAM_ID}",
          "${SUE_TELEGRAM_ID}"
        ]
      }
    }
  },
  "agents": {
    "router": {
      "mode": "static",
      "rules": [
        { "from": "telegram:${ALLEN_TELEGRAM_ID}", "agent": "allen" },
        { "from": "telegram:${KIM_TELEGRAM_ID}", "agent": "kim" },
        { "from": "telegram:${SUE_TELEGRAM_ID}", "agent": "sue" }
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
        "systemPrompt": "You are Allen's personal AI assistant. You have full access."
      },
      {
        "id": "kim",
        "displayName": "Kim's AI",
        "workspace": "/home/node/clawd-kim",
        "sandbox": { "mode": "all", "scope": "agent", "workspaceAccess": "none" },
        "tools": {
          "allow": ["sessions_list", "sessions_history", "sessions_send", "web_search", "web_fetch"],
          "deny": ["read", "write", "edit", "exec", "process", "browser", "elevated"]
        },
        "systemPrompt": "You are Kim's AI assistant. You can chat and search the web."
      },
      {
        "id": "sue",
        "displayName": "Sue's AI",
        "workspace": "/home/node/clawd-sue",
        "sandbox": { "mode": "all", "scope": "agent", "workspaceAccess": "none" },
        "tools": {
          "allow": ["sessions_list", "sessions_history", "sessions_send", "web_search", "web_fetch"],
          "deny": ["read", "write", "edit", "exec", "process", "browser", "elevated"]
        },
        "systemPrompt": "You are Sue's AI assistant. You can chat and search the web."
      }
    ]
  }
}
```

**WAIT!** The above JSON approach won't work well with env var substitution in Coolify. Let me create a better approach...

---

## Step 2: Create Config File Bootstrap Script

We need to add a script to your repo that generates the config file from environment variables.

Add this file to your fork: `scripts/coolify-bootstrap.sh`

```bash
#!/bin/bash
set -e

# Create config directory
mkdir -p /home/node/.clawdbot

# Generate clawdbot.json from environment variables
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
        "systemPrompt": "You are Allen's personal AI assistant with full access."
      },
      {
        "id": "kim",
        "displayName": "Kim's AI",
        "workspace": "/home/node/clawd-kim",
        "sandbox": { "mode": "all", "scope": "agent", "workspaceAccess": "none" },
        "tools": {
          "allow": ["sessions_list", "sessions_history", "sessions_send", "web_search", "web_fetch"],
          "deny": ["read", "write", "edit", "exec", "process", "browser", "elevated"]
        },
        "systemPrompt": "You are Kim's AI assistant. You can chat and search the web."
      },
      {
        "id": "sue",
        "displayName": "Sue's AI",
        "workspace": "/home/node/clawd-sue",
        "sandbox": { "mode": "all", "scope": "agent", "workspaceAccess": "none" },
        "tools": {
          "allow": ["sessions_list", "sessions_history", "sessions_send", "web_search", "web_fetch"],
          "deny": ["read", "write", "edit", "exec", "process", "browser", "elevated"]
        },
        "systemPrompt": "You are Sue's AI assistant. You can chat and search the web."
      }
    ]
  },
  "logging": {
    "level": "info",
    "file": "/home/node/.clawdbot/logs/clawdbot.log"
  }
}
EOF

# Create workspace directories
mkdir -p /home/node/clawd-allen
mkdir -p /home/node/clawd-kim
mkdir -p /home/node/clawd-sue

echo "Configuration generated successfully"

# Now run the actual gateway command
exec "$@"
```

Make it executable:
```bash
chmod +x scripts/coolify-bootstrap.sh
```

Commit and push to your fork.

---

## Step 3: Coolify Application Settings

### Build Settings
- **Build Command**: (leave default, Dockerfile handles it)
- **Build Pack**: Dockerfile

### Deployment Settings

**Start Command** (override the default CMD):
```bash
/bin/bash scripts/coolify-bootstrap.sh node dist/index.js gateway-daemon --bind lan --port 18789
```

This runs the bootstrap script first (generates config), then starts the gateway.

### Ports

Add these port mappings in Coolify:

```
18789:18789  (Gateway WebSocket)
18790:18790  (Bridge protocol)
```

### Volumes (Persistent Storage)

Add these volumes in Coolify:

```
clawdbot-config:/home/node/.clawdbot
clawdbot-workspaces:/home/node/clawd-allen
clawdbot-workspaces:/home/node/clawd-kim
clawdbot-workspaces:/home/node/clawd-sue
```

**Actually, simpler to use one volume:**
```
clawdbot-data:/home/node
```

This persists everything under `/home/node` (config, workspaces, logs).

### Health Check

Enable health check with:
- **Path**: `/` (Gateway serves a control UI here)
- **Port**: 18789
- **Interval**: 30s

---

## Step 4: Get Telegram Bot Token

1. Open Telegram and search for `@BotFather`
2. Send `/newbot`
3. Follow prompts:
   - **Bot name**: "Family AI Assistant" (or whatever you like)
   - **Bot username**: Must end in `bot`, e.g., `allenlinli_family_bot`
4. BotFather will reply with your bot token:
   ```
   Use this token to access the HTTP API:
   1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
   ```
5. Copy this token and add to Coolify as `TELEGRAM_BOT_TOKEN`

---

## Step 5: Get Telegram User IDs

Each family member needs to get their Telegram user ID:

1. Open Telegram
2. Search for `@userinfobot`
3. Send `/start`
4. Bot replies with your user ID (a number like `123456789`)
5. Add these to Coolify environment variables:
   - Allen → `ALLEN_TELEGRAM_ID`
   - Kim → `KIM_TELEGRAM_ID`
   - Sue → `SUE_TELEGRAM_ID`

---

## Step 6: Generate Gateway Token

On your local machine, run:

```bash
openssl rand -base64 32
```

Copy the output and add to Coolify as `CLAWDBOT_GATEWAY_TOKEN`.

---

## Step 7: Deploy!

1. Make sure all environment variables are set in Coolify
2. Push the bootstrap script to your GitHub fork
3. Click "Deploy" in Coolify
4. Watch the build logs
5. Once deployed, check logs for any errors

---

## Step 8: Test It

### Test the Gateway

Open: https://clawbot.allenlinli.com

You should see the Clawdbot control UI. Paste your `CLAWDBOT_GATEWAY_TOKEN` to authenticate.

### Test Telegram

1. Search for your bot username in Telegram (e.g., `@allenlinli_family_bot`)
2. Send a message: "Hello!"
3. The bot should respond (routed to your agent based on your Telegram ID)

---

## Troubleshooting

### Check Logs

In Coolify, go to your application and click "Logs" to see real-time output.

### Common Issues

**Bot doesn't respond:**
- Check `TELEGRAM_BOT_TOKEN` is correct
- Check your Telegram user ID is in the allowlist
- Check gateway logs for errors

**Gateway won't start:**
- Check all required env vars are set
- Check bootstrap script ran successfully
- Check volumes are mounted correctly

**Config not generated:**
- Check bootstrap script has correct permissions
- Check env vars are being substituted correctly
- SSH into container and check `/home/node/.clawdbot/clawdbot.json`

---

## Next Steps

Once working:

1. **Backup strategy**: Coolify can backup your `clawdbot-data` volume
2. **Monitoring**: Set up Coolify alerts for container crashes
3. **Updates**: Pull latest from upstream clawdbot repo, merge to your fork, redeploy

---

## Summary Checklist

- [ ] Add all environment variables in Coolify
- [ ] Create and push `scripts/coolify-bootstrap.sh` to your fork
- [ ] Set start command in Coolify
- [ ] Configure ports: 18789, 18790
- [ ] Add volume: `clawdbot-data:/home/node`
- [ ] Create Telegram bot via @BotFather
- [ ] Get Telegram user IDs via @userinfobot
- [ ] Generate gateway token with openssl
- [ ] Deploy in Coolify
- [ ] Test via web UI and Telegram

# Multi-Agent Configuration Patterns

Detailed patterns for routing and security isolation in multi-user deployments.

## Routing Strategies

### Static Routing

Best for: Known users, family/team deployments

```json
{
  "router": {
    "mode": "static",
    "rules": [
      { "from": "telegram:USER_ID_1", "agent": "allen" },
      { "from": "telegram:USER_ID_2", "agent": "kim" },
      { "from": "whatsapp:+1234567890", "agent": "sue" }
    ]
  }
}
```

### Dynamic Routing

Best for: Many users, tenant-based systems

```json
{
  "router": {
    "mode": "dynamic",
    "createOnDemand": true,
    "template": "default-agent"
  }
}
```

## Security Levels

### Level 1: Full Access (Admin)

```json
{
  "id": "admin",
  "sandbox": { "mode": "off" },
  "workspace": "/app/workspace-admin"
}
```

Use for: Trusted administrators, developers

### Level 2: Restricted Assistant (Family/Team)

```json
{
  "id": "family-member",
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
  "workspace": "/app/workspace-user"
}
```

Use for: Family members, team members with limited access

### Level 3: Public/Guest (Maximum Restriction)

```json
{
  "id": "guest",
  "sandbox": {
    "mode": "all",
    "scope": "agent",
    "workspaceAccess": "none"
  },
  "tools": {
    "allow": ["sessions_send"],
    "deny": ["*"]
  },
  "rateLimit": {
    "messages": 10,
    "window": "1h"
  }
}
```

Use for: Public bots, untrusted users

## Channel Allowlists

### Telegram

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "${TELEGRAM_BOT_TOKEN}",
      "dm": {
        "policy": "allowlist",
        "allowFrom": [
          "${USER1_TELEGRAM_ID}",
          "${USER2_TELEGRAM_ID}"
        ]
      }
    }
  }
}
```

Get Telegram ID: DM `@userinfobot` and send `/start`

### WhatsApp

```json
{
  "channels": {
    "whatsapp": {
      "enabled": true,
      "dm": {
        "policy": "allowlist",
        "allowFrom": [
          "+1234567890",
          "+0987654321"
        ]
      }
    }
  }
}
```

## Workspace Isolation

Each agent gets isolated workspace:

```bash
/app/
├── workspace-admin/     # Full access workspace
├── workspace-user1/     # Isolated workspace
└── workspace-user2/     # Isolated workspace
```

Bootstrap script should create all workspaces:

```bash
mkdir -p /app/workspace-admin
mkdir -p /app/workspace-user1
mkdir -p /app/workspace-user2
```

## Environment Variable Pattern

```bash
# User routing
ALLEN_TELEGRAM_ID=123456789
KIM_TELEGRAM_ID=987654321
SUE_TELEGRAM_ID=555666777

# Channel tokens
TELEGRAM_BOT_TOKEN=<token>
WHATSAPP_CREDENTIALS=<creds>

# Auth
GATEWAY_TOKEN=<random-token>
```

Generate random tokens:
```bash
openssl rand -base64 32
```

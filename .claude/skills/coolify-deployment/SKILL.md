---
name: coolify-deployment
description: Deploy containerized applications to Coolify using environment variable-driven configuration. Use when deploying to Coolify PaaS, configuring container apps with secrets, or setting up bootstrap-based configuration patterns.
---

# Coolify Deployment

Deploy Dockerized applications to Coolify with environment variable-driven configuration.

## Core Pattern

**Bootstrap script generates config from env vars at container startup** instead of committing static config files.

Benefits:
- Secrets stay in Coolify UI (never in git)
- Same codebase works across environments
- Configuration changes without rebuilding

## Bootstrap Script Template

Create `scripts/coolify-bootstrap.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 [App Name] Bootstrap"
echo "=============================="

# Create config directory
mkdir -p /app/config

# Generate config from environment variables
cat > /app/config/config.json <<EOF
{
  "port": ${PORT:-3000},
  "database": {
    "host": "${DB_HOST}",
    "password": "${DB_PASSWORD}"
  },
  "auth": {
    "secret": "${AUTH_SECRET}"
  }
}
EOF

echo "✅ Configuration generated"

# Verify required environment variables
MISSING_VARS=()
[ -z "$DB_HOST" ] && MISSING_VARS+=("DB_HOST")
[ -z "$DB_PASSWORD" ] && MISSING_VARS+=("DB_PASSWORD")
[ -z "$AUTH_SECRET" ] && MISSING_VARS+=("AUTH_SECRET")

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
  echo "❌ Missing required environment variables:"
  for var in "${MISSING_VARS[@]}"; do
    echo "   - $var"
  done
  exit 1
fi

echo "✅ All required environment variables set"

# Create necessary directories
mkdir -p /app/data /app/logs

# Now run the actual application command
exec "$@"
```

Make executable:
```bash
chmod +x scripts/coolify-bootstrap.sh
```

## Coolify Configuration

### 1. Environment Variables

In Coolify UI, add:

**Core Settings** (copy exactly):
```bash
NODE_ENV=production
PORT=3000
HOME=/app
```

**Secrets** (from Bitwarden):
```bash
DB_PASSWORD=<from-bitwarden>
AUTH_SECRET=<from-bitwarden>
API_KEY=<from-bitwarden>
```

### 2. Start Command

Override default CMD with bootstrap wrapper:

```bash
/bin/bash scripts/coolify-bootstrap.sh node dist/index.js
```

Pattern: `bootstrap-script actual-start-command`

### 3. Ports

Format: `host:container`

```
3000:3000      # Application
8080:8080      # Admin panel (if needed)
```

Mark primary port for domain routing.

### 4. Volumes (Persistent Storage)

Format: `volume-name:/mount/path`

```
app-data:/app/data          # Application data
app-logs:/app/logs          # Log files
app-config:/app/config      # Generated config (optional)
```

**Critical**: Volumes persist across deployments and restarts.

### 5. Health Check

```
Type: HTTP
Port: 3000
Path: /health
Interval: 30s
Timeout: 10s
Retries: 3
```

Implement `/health` endpoint in your app.

### 6. Domain/SSL

- Set custom domain in Coolify
- SSL/TLS handled automatically via Traefik
- Ensure DNS points to VPS IP

## Multi-User/Multi-Agent Pattern

For applications with user routing (e.g., family PAI, team bots):

### Router Configuration

```json
{
  "router": {
    "mode": "static",
    "rules": [
      { "from": "telegram:123456789", "agent": "user1" },
      { "from": "telegram:987654321", "agent": "user2" }
    ]
  },
  "agents": [
    {
      "id": "user1",
      "workspace": "/app/workspace-user1",
      "sandbox": { "mode": "off" }
    },
    {
      "id": "user2",
      "workspace": "/app/workspace-user2",
      "sandbox": {
        "mode": "all",
        "scope": "agent",
        "workspaceAccess": "none"
      },
      "tools": {
        "allow": ["web_search", "web_fetch"],
        "deny": ["read", "write", "exec"]
      }
    }
  ]
}
```

### Security Isolation

- **Sandbox mode: "off"** - Full access (admin users)
- **Sandbox mode: "all"** - Isolated (restricted users)
- **workspaceAccess: "none"** - No filesystem access
- **Tool policies** - Allow/deny specific capabilities

## Deployment Checklist

- [ ] Bootstrap script created and executable
- [ ] Required environment variables documented
- [ ] Start command configured in Coolify
- [ ] Port mappings defined
- [ ] Volumes configured for persistent data
- [ ] Health check endpoint implemented
- [ ] Domain DNS configured
- [ ] Secrets stored in Bitwarden
- [ ] Environment variables added to Coolify UI
- [ ] Test deployment and verify logs

## Troubleshooting

See [troubleshooting guide](references/troubleshooting.md) for common issues and solutions.

## References

- [Multi-agent configuration](references/multi-agent.md)
- [Secret management](references/secrets.md)

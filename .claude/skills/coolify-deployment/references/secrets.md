# Secret Management for Coolify Deployments

How to securely manage secrets when deploying to Coolify.

## Core Principle

**Secrets flow**: Bitwarden → Manual copy → Coolify UI → Container environment variables → Config generation

Never commit secrets to git.

## Secret Types

### 1. API Keys

Examples: Anthropic API key, OpenAI API key, third-party services

**Storage**: Bitwarden vault item
**Format**: Single secure note or password field
**Usage**: Copy to Coolify environment variable

```bash
# In Coolify
ANTHROPIC_API_KEY=sk-ant-api03-...
OPENAI_API_KEY=sk-proj-...
```

### 2. Authentication Tokens

Examples: Gateway tokens, webhook secrets, session keys

**Generation**:
```bash
openssl rand -base64 32
openssl rand -hex 40
```

**Storage**: Store generated value in Bitwarden
**Usage**: Copy to Coolify

```bash
# In Coolify
GATEWAY_TOKEN=a1b2c3d4e5f6g7h8i9j0...
WEBHOOK_SECRET=abc123def456...
```

### 3. Bot/Channel Tokens

Examples: Telegram bot token, WhatsApp credentials

**Acquisition**:
- Telegram: @BotFather → `/newbot`
- WhatsApp: Meta Developer Console

**Storage**: Bitwarden vault item
**Usage**: Copy to Coolify

```bash
# In Coolify
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHI...
```

### 4. User Identifiers

Examples: Telegram user IDs, phone numbers

**Acquisition**:
- Telegram ID: DM `@userinfobot`, send `/start`
- Phone: User provides

**Storage**: Can be in Bitwarden or plaintext (not truly secret)
**Usage**: Copy to Coolify

```bash
# In Coolify
ALLEN_TELEGRAM_ID=123456789
KIM_TELEGRAM_ID=987654321
```

### 5. Database Passwords

**Generation**:
```bash
openssl rand -base64 32
```

**Storage**: Bitwarden (labeled clearly)
**Usage**: Copy to Coolify

```bash
# In Coolify
DB_PASSWORD=...
REDIS_PASSWORD=...
```

## Bitwarden Organization

### Folder Structure

```
Bitwarden/
├── Infrastructure/
│   ├── Coolify Deployment - Project X
│   │   ├── API Keys
│   │   ├── Gateway Token
│   │   └── Bot Tokens
│   └── Database Passwords
└── Personal/
    └── Telegram User IDs
```

### Item Naming Convention

Format: `[service]-[environment]-[type]`

Examples:
- `clawdbot-prod-gateway-token`
- `clawdbot-prod-telegram-bot`
- `clawdbot-prod-anthropic-key`

## Coolify Environment Variable Organization

Group by category with comments:

```bash
# Core Settings
NODE_ENV=production
PORT=3000
HOME=/app

# API Keys
ANTHROPIC_API_KEY=<from-bitwarden>

# Bot Configuration
TELEGRAM_BOT_TOKEN=<from-bitwarden>
GATEWAY_TOKEN=<from-bitwarden>

# User Identifiers
ALLEN_TELEGRAM_ID=123456789
KIM_TELEGRAM_ID=987654321

# Database
DB_HOST=db.example.com
DB_PASSWORD=<from-bitwarden>
```

## Secret Rotation

### When to Rotate

- Quarterly (scheduled)
- After team member departure
- After suspected compromise
- After system breach

### Rotation Process

1. Generate new secret
2. Update in Bitwarden
3. Update in Coolify environment variables
4. Restart application (Coolify handles this)
5. Verify application works
6. Delete old secret from Bitwarden (after grace period)

## Security Best Practices

### DO

✅ Store all secrets in Bitwarden
✅ Use strong random generation (openssl)
✅ Label secrets clearly in Bitwarden
✅ Rotate secrets regularly
✅ Use environment variables in containers
✅ Verify secrets work before deleting old ones

### DON'T

❌ Commit secrets to git (even encrypted)
❌ Share secrets in chat/email
❌ Reuse secrets across environments
❌ Store secrets in code comments
❌ Log secrets to console/files
❌ Use weak/predictable secrets

## Troubleshooting

### Secret not working

1. Check for typos in variable name
2. Verify no trailing whitespace
3. Confirm secret format is correct
4. Check if secret expired (some APIs)
5. Verify environment variable is set in container

### Verify in container

```bash
# Coolify console
echo $GATEWAY_TOKEN
env | grep TELEGRAM
```

### Bootstrap script validation

Add to bootstrap script:

```bash
# Debug: Show first 4 chars of secrets
echo "GATEWAY_TOKEN: ${GATEWAY_TOKEN:0:4}..."
echo "DB_PASSWORD: ${DB_PASSWORD:0:4}..."
```

## Backup Secrets

### Manual Backup

Export Bitwarden vault regularly (encrypted JSON).

### Automated Backup

Use Bitwarden CLI + Ansible Vault pattern (see `.claude/rules/bitwarden.md`).

## Compliance

If handling sensitive data:
- Document secret access (who has access)
- Implement audit logging
- Use secrets management service (Bitwarden Secrets Manager)
- Follow data protection regulations (GDPR, etc.)

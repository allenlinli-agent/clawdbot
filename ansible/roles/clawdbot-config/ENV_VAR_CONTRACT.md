# Environment Variable Contract

This document defines the contract between the Ansible deployment playbooks and the Clawdbot bootstrap script (`scripts/coolify-bootstrap.sh`).

## Overview

The bootstrap script generates `/home/node/.clawdbot/clawdbot.json` at container startup using environment variables set by Ansible in the Coolify application configuration. Ansible sets these variables via the Coolify API, and Coolify passes them to the container at runtime.

## Required Environment Variables

### Core Configuration Variables

These are set by Ansible from inventory/group_vars:

| Variable | Source | Purpose | Example |
|----------|--------|---------|---------|
| `HOME` | Ansible static | Home directory for node user | `/home/node` |
| `TERM` | Ansible static | Terminal type for proper output | `xterm-256color` |
| `NODE_ENV` | Ansible static | Node.js environment | `production` |
| `CLAWDBOT_GATEWAY_PORT` | Ansible static | WebSocket gateway port | `18789` |
| `CLAWDBOT_GATEWAY_BIND` | Ansible static | Gateway bind interface | `lan` |
| `CLAWDBOT_BRIDGE_PORT` | Ansible static | Bridge protocol port | `18790` |

### Secret Variables

These are retrieved by Ansible from Bitwarden Secrets Manager:

| Variable | Source | Purpose | Format |
|----------|--------|---------|--------|
| `TELEGRAM_BOT_TOKEN` | Bitwarden | Telegram bot API token | String (from @BotFather) |
| `ANTHROPIC_API_KEY` | Bitwarden | Claude API key | String (sk-ant-...) |
| `CLAWDBOT_GATEWAY_TOKEN` | Bitwarden | Gateway authentication token | Base64 string (32+ bytes) |
| `ALLEN_TELEGRAM_ID` | Bitwarden | Allen's Telegram user ID | Numeric string |
| `KIM_TELEGRAM_ID` | Bitwarden | Kim's Telegram user ID | Numeric string |
| `SUE_TELEGRAM_ID` | Bitwarden | Sue's Telegram user ID | Numeric string |

## Bootstrap Script Behavior

The `scripts/coolify-bootstrap.sh` script:

1. **Creates directories**: `/home/node/.clawdbot/logs`, workspace dirs for each agent
2. **Generates config**: Substitutes env vars into `/home/node/.clawdbot/clawdbot.json`
3. **Validates env vars**: Checks that all required secret variables are non-empty
4. **Fails fast**: Exits with code 1 if any required variable is missing
5. **Starts application**: Executes the provided command (gateway daemon)

## Configuration Generation

The bootstrap script generates a JSON configuration with:

### Gateway Settings
- Port: `18789` (hardcoded, matches `CLAWDBOT_GATEWAY_PORT`)
- Auth mode: `token`
- Auth token: `$CLAWDBOT_GATEWAY_TOKEN`

### Telegram Channel
- Enabled: `true`
- Bot token: `$TELEGRAM_BOT_TOKEN`
- DM policy: `allowlist`
- Allowed users: `$ALLEN_TELEGRAM_ID`, `$KIM_TELEGRAM_ID`, `$SUE_TELEGRAM_ID`

### Agent Routing
- Mode: `static`
- Routes:
  - `telegram:$ALLEN_TELEGRAM_ID` → `allen` agent
  - `telegram:$KIM_TELEGRAM_ID` → `kim` agent
  - `telegram:$SUE_TELEGRAM_ID` → `sue` agent

### Agent Configurations

**Allen's Agent:**
- Full access (sandbox mode: `off`)
- Workspace: `/home/node/clawd-allen`
- All tools enabled

**Kim's Agent:**
- Restricted access (sandbox mode: `all`, scope: `agent`)
- Workspace: `/home/node/clawd-kim`
- Allowed tools: sessions, web_search, web_fetch
- Denied tools: read, write, edit, exec, process, browser, elevated

**Sue's Agent:**
- Restricted access (sandbox mode: `all`, scope: `agent`)
- Workspace: `/home/node/clawd-sue`
- Allowed tools: sessions, web_search, web_fetch
- Denied tools: read, write, edit, exec, process, browser, elevated

## Validation

### Ansible-side Validation (clawdbot-config role)
- Verifies all required env vars are set in Coolify via API
- Validates bootstrap script exists and is executable
- Runs before application deployment

### Bootstrap-side Validation
- Checks that secret variables are non-empty at container startup
- Exits with error if validation fails
- Prevents misconfigured deployment from starting

## Maintenance

### Adding New Environment Variables

If you need to add a new environment variable:

1. **Update Ansible role** (`coolify-app/tasks/env-vars.yml`):
   - Add variable to appropriate task (core or secrets)
   - Use `no_log: true` for secrets

2. **Update validation** (`clawdbot-config/defaults/main.yml`):
   - Add to `required_env_vars` list

3. **Update bootstrap script** (`scripts/coolify-bootstrap.sh`):
   - Add variable to validation checks
   - Use variable in generated config

4. **Update this contract**:
   - Document new variable in appropriate table
   - Describe its purpose and format

### Removing Environment Variables

1. Remove from all three locations (Ansible, validation, bootstrap)
2. Update this contract documentation
3. Test deployment to ensure no breakage

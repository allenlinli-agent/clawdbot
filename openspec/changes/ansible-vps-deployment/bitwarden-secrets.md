# Bitwarden Secrets Manager Setup

## Project: clawdbot

These secrets should be created in your Bitwarden Secrets Manager "clawdbot" project.

### Required Secrets

| Secret Key | Description | How to Get |
|------------|-------------|------------|
| `TELEGRAM_BOT_TOKEN` | Telegram bot token | 1. DM @BotFather<br>2. `/newbot`<br>3. Follow prompts<br>4. Copy token |
| `ANTHROPIC_API_KEY` | Anthropic API key | From your Claude Code subscription |
| `CLAWDBOT_GATEWAY_TOKEN` | Gateway auth token | Generate: `openssl rand -base64 32` |
| `ALLEN_TELEGRAM_ID` | Allen's Telegram user ID | DM @userinfobot and send `/start` |
| `KIM_TELEGRAM_ID` | Kim's Telegram user ID | Kim DMs @userinfobot and sends `/start` |
| `SUE_TELEGRAM_ID` | Sue's Telegram user ID | Sue DMs @userinfobot and sends `/start` |
| `VPS_SSH_KEY` | SSH private key for VPS | Your existing SSH key for 72.60.28.11 |

### Creating Secrets via BWS CLI

```bash
# 1. Install BWS CLI (if not already)
npm install -g @bitwarden/sdk-sm

# 2. Authenticate
bws login

# 3. Get your clawdbot project ID
bws project list

# 4. Create secrets
bws secret create TELEGRAM_BOT_TOKEN "paste-token-here" --project-id <project-id>
bws secret create ANTHROPIC_API_KEY "sk-ant-..." --project-id <project-id>
bws secret create CLAWDBOT_GATEWAY_TOKEN "$(openssl rand -base64 32)" --project-id <project-id>
bws secret create ALLEN_TELEGRAM_ID "123456789" --project-id <project-id>
bws secret create KIM_TELEGRAM_ID "987654321" --project-id <project-id>
bws secret create SUE_TELEGRAM_ID "555666777" --project-id <project-id>
```

### Ansible Retrieval Pattern

Ansible will retrieve these secrets using the `bitwarden_secrets_manager` lookup:

```yaml
- name: Get secrets from Bitwarden
  set_fact:
    telegram_token: "{{ lookup('community.general.bitwarden_secrets_manager', 'TELEGRAM_BOT_TOKEN') }}"
    anthropic_api_key: "{{ lookup('community.general.bitwarden_secrets_manager', 'ANTHROPIC_API_KEY') }}"
    gateway_token: "{{ lookup('community.general.bitwarden_secrets_manager', 'CLAWDBOT_GATEWAY_TOKEN') }}"
  no_log: true
```

### Environment Variables for Ansible

Set the BWS access token before running Ansible:

```bash
export BWS_ACCESS_TOKEN="your-bws-access-token"
ansible-playbook -i inventory.yml site.yml
```

Get your BWS access token from: https://vault.bitwarden.com/#/sm/access-tokens

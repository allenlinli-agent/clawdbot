# Clawdbot Ansible Automation

Automate Clawdbot deployment to Coolify-managed VPS with Ansible.

## Prerequisites

1. **Ansible 2.15+** installed locally
2. **Bitwarden Secrets Manager** project configured with secrets
3. **Coolify** instance running (https://coolify.allenlinli.com)
4. **SSH access** to your VPS
5. **Coolify API token** generated from UI

## Quick Start

### 1. Install Ansible and Dependencies

```bash
# Install Ansible
pip install ansible

# Install required Ansible collection
ansible-galaxy collection install community.general
```

### 2. Set Up Bitwarden Secrets Manager

Create a Bitwarden Secrets Manager project named `clawdbot` with these secrets:

```bash
TELEGRAM_BOT_TOKEN      # From @BotFather on Telegram
ANTHROPIC_API_KEY       # Your Claude API key
CLAWDBOT_GATEWAY_TOKEN  # Generate: openssl rand -base64 32
ALLEN_TELEGRAM_ID       # From @userinfobot on Telegram
KIM_TELEGRAM_ID         # From @userinfobot on Telegram
SUE_TELEGRAM_ID         # From @userinfobot on Telegram
```

Get your BWS access token from: https://vault.bitwarden.com/#/sm/access-tokens

### 3. Configure Coolify API Token

1. Go to your Coolify instance: https://coolify.allenlinli.com
2. Navigate to **Keys & Tokens** → **API tokens**
3. Create a new token with full access
4. Copy the token (shown only once)

### 4. Set Up Inventory

```bash
# Copy inventory template
cp inventory/production.yml.example inventory/production.yml

# Edit inventory with your values
vi inventory/production.yml
```

**Required variables:**
- `ansible_host`: Your VPS IP (72.60.28.11)
- `coolify_app_uuid`: Your Coolify app UUID from the app URL
  - Example: From `https://coolify.allen linli.com/.../application/c4w8c8kwwgw4cggk4k4kco8w`
  - Use: `c4w8c8kwwgw4cggk4k4kco8w`

### 5. Set Up Ansible Vault

```bash
# Copy vault template
cp vault/secrets.yml.example vault/secrets.yml

# Edit and add your Coolify API token
vi vault/secrets.yml

# Encrypt the vault file
ansible-vault encrypt vault/secrets.yml
# Enter a strong password and store it in Bitwarden
```

### 6. Run the Playbook

```bash
# Export Bitwarden access token
export BWS_ACCESS_TOKEN="your-bws-access-token"

# Run the deployment playbook
ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --ask-vault-pass
```

## What This Does

The playbook performs these tasks:

### VPS Provisioning (`vps-provision` role)
- Updates system packages
- Installs Docker and Docker Compose
- Creates `clawdbot` user with Docker access
- Hardens SSH (disables password auth, disables root login)
- Configures UFW firewall (allows ports 22, 80, 443, 18789, 18790)

### Coolify App Configuration (`coolify-app` role)
- Retrieves secrets from Bitwarden Secrets Manager
- Configures environment variables in Coolify via API
- Sets application settings (build pack, start command, ports, volumes)
- Configures health checks

## Roles

- **vps-provision**: Set up VPS infrastructure
- **coolify-app**: Configure Coolify application via API

## Testing

```bash
# Dry run (check mode)
ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --check --ask-vault-pass

# Run with verbose output
ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --ask-vault-pass -vvv

# Run only VPS provisioning
ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --tags vps --ask-vault-pass

# Run only Coolify configuration
ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --tags coolify --ask-vault-pass
```

## Troubleshooting

### Bitwarden lookup fails
- Verify `BWS_ACCESS_TOKEN` is exported: `echo $BWS_ACCESS_TOKEN`
- Verify secrets exist in Bitwarden Secrets Manager
- Check project name matches `clawdbot`

### Coolify API returns 401 Unauthorized
- Verify API token in `vault/secrets.yml`
- Regenerate token from Coolify UI if needed
- Check token has correct permissions

### Ansible Vault password incorrect
- Retrieve password from Bitwarden
- Re-encrypt vault: `ansible-vault rekey vault/secrets.yml`

### SSH connection fails
- Verify `ansible_host` in inventory
- Test SSH manually: `ssh root@72.60.28.11`
- Check SSH key path in inventory

## Next Steps

After deployment:

1. **Verify deployment**: https://clawbot.allenlinli.com
2. **Test Telegram bot**: Send a message to your bot
3. **Monitor logs**: Check Coolify logs viewer
4. **Test agents**: Verify Allen, Kim, and Sue can use their respective agents

## Directory Structure

```
ansible/
├── group_vars/
│   └── all.yml              # Shared variables
├── inventory/
│   ├── production.yml.example  # Inventory template
│   └── production.yml       # Your inventory (gitignored)
├── playbooks/
│   └── deploy-clawdbot-coolify.yml  # Main playbook
├── roles/
│   ├── vps-provision/       # VPS setup role
│   │   ├── tasks/
│   │   ├── defaults/
│   │   └── handlers/
│   └── coolify-app/         # Coolify config role
│       ├── tasks/
│       └── defaults/
├── vault/
│   ├── secrets.yml.example  # Vault template
│   └── secrets.yml          # Your secrets (gitignored, encrypted)
└── README.md               # This file
```

## Security Notes

- Never commit `inventory/production.yml` or `vault/secrets.yml` to git
- Store Ansible Vault password in Bitwarden
- Rotate secrets regularly in Bitwarden Secrets Manager
- Use read-only Coolify API token if you only need to read data
- Review firewall rules before deployment

## Support

For issues or questions:
- Check Coolify API docs: https://coolify.io/docs/api-reference
- Check Bitwarden Secrets Manager docs: https://bitwarden.com/help/secrets-manager-overview
- Review Ansible logs with `-vvv` flag

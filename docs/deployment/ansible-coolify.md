# Ansible Deployment Guide for Clawdbot on Coolify

This guide describes how to deploy Clawdbot to a Coolify-managed VPS using Ansible automation.

## Overview

The Ansible deployment automates the entire Clawdbot deployment process:

1. **VPS Provisioning** - Install Docker, configure firewall, harden SSH
2. **Coolify Configuration** - Set environment variables, configure application settings
3. **Configuration Validation** - Verify all required settings are in place
4. **Deployment Validation** - Health checks, port checks, Telegram connectivity

## Prerequisites

### Software Requirements

- **Ansible 2.15+** installed on your local machine
- **Ansible Community Collection**: `ansible-galaxy collection install community.general`
- **SSH access** to the target VPS with key-based authentication
- **Coolify** installed and running on the VPS or management host
- **Bitwarden Secrets Manager** account with CLI access

### Access Requirements

- SSH private key for VPS access
- Coolify API token (generate from Coolify UI: Settings → Keys & Tokens → API Tokens)
- Bitwarden Secrets Manager access token (BWS_ACCESS_TOKEN)
- Telegram bot token (from @BotFather)
- Anthropic API key (from Claude console)
- Telegram user IDs for Allen, Kim, and Sue (from @userinfobot)

## Bitwarden Secrets Manager Setup

### 1. Create Bitwarden Project

Create a project named `clawdbot` in Bitwarden Secrets Manager.

### 2. Add Secrets

Add the following secrets to the `clawdbot` project:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `TELEGRAM_BOT_TOKEN` | Telegram bot API token | Create bot via @BotFather on Telegram |
| `ANTHROPIC_API_KEY` | Claude API key | Get from https://console.anthropic.com |
| `CLAWDBOT_GATEWAY_TOKEN` | Gateway auth token | Generate: `openssl rand -base64 32` |
| `ALLEN_TELEGRAM_ID` | Allen's Telegram user ID | Send `/start` to @userinfobot |
| `KIM_TELEGRAM_ID` | Kim's Telegram user ID | Send `/start` to @userinfobot |
| `SUE_TELEGRAM_ID` | Sue's Telegram user ID | Send `/start` to @userinfobot |

### 3. Generate Access Token

1. In Bitwarden Secrets Manager, navigate to your project
2. Go to "Machine Accounts" → "Create New"
3. Name it "clawdbot-ansible"
4. Grant read access to the `clawdbot` project
5. Generate and save the access token

**Important**: Save the access token securely. You'll need to export it as `BWS_ACCESS_TOKEN` before running the playbook.

## Ansible Setup

### 1. Install Ansible

```bash
# macOS (Homebrew)
brew install ansible

# Ubuntu/Debian
sudo apt update && sudo apt install ansible

# Verify version (must be 2.15+)
ansible --version
```

### 2. Install Required Collection

```bash
ansible-galaxy collection install community.general
```

### 3. Configure Inventory

Copy the example inventory and customize it:

```bash
cd ansible
cp inventory/production.yml.example inventory/production.yml
```

Edit `inventory/production.yml` with your VPS details:

```yaml
all:
  hosts:
    clawdbot_vps:
      ansible_host: YOUR_VPS_IP
      ansible_user: root  # or your SSH user
      ansible_ssh_private_key_file: ~/.ssh/id_rsa  # path to your SSH key

  vars:
    # Coolify settings
    coolify_api_url: "http://YOUR_COOLIFY_HOST:8000/api/v1"
    coolify_app_uuid: "YOUR_APP_UUID"  # Get from Coolify UI
    coolify_app_domain: "clawbot.yourdomain.com"

    # Bitwarden settings
    bitwarden_project_name: "clawdbot"
```

**Security**: The `inventory/production.yml` file is gitignored to prevent accidentally committing sensitive data.

### 4. Configure Ansible Vault

Create and encrypt the vault file for infrastructure secrets:

```bash
cd ansible

# Create vault file
cat > vault/secrets.yml <<EOF
---
# Coolify API token (from Coolify UI: Settings → API Tokens)
coolify_api_token: "YOUR_COOLIFY_API_TOKEN_HERE"
EOF

# Encrypt the vault
ansible-vault encrypt vault/secrets.yml
```

You'll be prompted to create a vault password. **Store this password securely in Bitwarden**.

To edit the vault later:

```bash
ansible-vault edit vault/secrets.yml
```

## Deployment Process

### 1. Export Bitwarden Access Token

```bash
export BWS_ACCESS_TOKEN="your_bws_access_token_here"
```

### 2. Run the Playbook

Full deployment with all steps:

```bash
cd ansible
ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --ask-vault-pass
```

You'll be prompted for the vault password you created earlier.

### 3. Monitor Deployment

The playbook will:

1. ✅ Validate BWS_ACCESS_TOKEN is set
2. ✅ Provision VPS (install Docker, configure firewall, harden SSH)
3. ✅ Retrieve secrets from Bitwarden
4. ✅ Configure Coolify application settings
5. ✅ Set environment variables in Coolify
6. ✅ Validate configuration
7. ✅ Verify deployment health

Expected output:

```
PLAY [Deploy Clawdbot to Coolify-managed VPS] ********************

TASK [vps-provision : Update apt cache] **************************
ok: [clawdbot_vps]

TASK [vps-provision : Install Docker] ****************************
changed: [clawdbot_vps]

...

TASK [deployment-validation : Display validation report] *********
ok: [clawdbot_vps] => {
    "msg": "DEPLOYMENT VALIDATION: SUCCESS"
}

PLAY RECAP *******************************************************
clawdbot_vps               : ok=47   changed=12   failed=0
```

### 4. Verify Deployment

After deployment completes:

1. **Check health endpoint**:
   ```bash
   curl http://YOUR_VPS_IP:18789/
   ```

2. **Test Telegram bot**:
   - Send a message to your bot on Telegram
   - Verify you receive a response

3. **View logs** in Coolify UI:
   - Navigate to your application
   - Click "Logs" tab
   - Verify no errors

## Running Specific Steps

Use tags to run only specific parts of the deployment:

```bash
# Only provision VPS
ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --tags vps --ask-vault-pass

# Only configure Coolify application
ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --tags coolify --ask-vault-pass

# Only run validation
ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --tags validation --ask-vault-pass

# Dry run (check mode)
ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --check --ask-vault-pass
```

## Updating Configuration

### Update Environment Variables

If you need to update environment variables (e.g., rotate secrets):

1. Update secrets in Bitwarden Secrets Manager
2. Re-run the Coolify configuration:
   ```bash
   ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --tags coolify --ask-vault-pass
   ```
3. Restart the application in Coolify UI

### Update Application Code

To deploy a new version of Clawdbot:

1. Push changes to your git repository
2. In Coolify UI, trigger a rebuild or redeploy
3. Run validation to verify the update:
   ```bash
   ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --tags validation --ask-vault-pass
   ```

## Troubleshooting

### BWS_ACCESS_TOKEN Not Set

**Error**: `BWS_ACCESS_TOKEN environment variable must be set`

**Solution**: Export the token before running the playbook:
```bash
export BWS_ACCESS_TOKEN="your_token_here"
```

### Secret Not Found in Bitwarden

**Error**: `Secret 'TELEGRAM_BOT_TOKEN' not found in Bitwarden project`

**Solution**:
1. Log into Bitwarden Secrets Manager
2. Verify the secret exists in the `clawdbot` project
3. Check the secret name matches exactly (case-sensitive)

### Coolify API Authentication Failed

**Error**: `401 Unauthorized` when calling Coolify API

**Solution**:
1. Verify `coolify_api_token` in `vault/secrets.yml` is correct
2. Regenerate token from Coolify UI if needed:
   - Settings → Keys & Tokens → API Tokens → Create New
3. Update vault: `ansible-vault edit vault/secrets.yml`

### Container Not Running

**Error**: `Container 'clawdbot' is not running`

**Solution**:
1. Check Coolify application logs for errors
2. Verify environment variables are set correctly
3. Check bootstrap script logs:
   ```bash
   ssh user@vps 'docker logs clawdbot'
   ```
4. Common causes:
   - Missing environment variable (bootstrap script validates and fails)
   - Invalid API key or token
   - Network connectivity issues

### Port Not Accessible

**Error**: `Gateway port 18789 is not accepting connections`

**Solution**:
1. Check UFW firewall rules on VPS:
   ```bash
   ssh user@vps 'sudo ufw status'
   ```
2. Verify port is listening:
   ```bash
   ssh user@vps 'netstat -tuln | grep 18789'
   ```
3. Check Docker port mappings:
   ```bash
   ssh user@vps 'docker ps'
   ```

### Health Check Fails

**Error**: `Health check endpoint returned unexpected status`

**Solution**:
1. Wait longer (application may still be starting)
2. Check container logs for startup errors
3. Verify gateway is listening:
   ```bash
   curl -v http://YOUR_VPS_IP:18789/
   ```

## Rollback Procedures

### Rollback Application Version

1. In Coolify UI, navigate to your application
2. Go to "Deployments" tab
3. Find previous successful deployment
4. Click "Redeploy" on the older version

### Rollback Configuration

1. Update secrets in Bitwarden back to previous values
2. Re-run Coolify configuration:
   ```bash
   ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml --tags coolify --ask-vault-pass
   ```
3. Restart application in Coolify UI

### Full Rollback

If deployment is completely broken:

1. Stop the application in Coolify UI
2. Restore VPS from backup/snapshot (if available)
3. Re-run full deployment with known-good configuration

## Security Best Practices

1. **Never commit secrets to git**:
   - `inventory/production.yml` is gitignored
   - `vault/secrets.yml` is encrypted
   - Use Bitwarden for application secrets

2. **Rotate secrets regularly**:
   - Update in Bitwarden
   - Re-run deployment to apply changes

3. **Limit API token permissions**:
   - Coolify API token should have minimal necessary permissions
   - BWS access token should only have read access to `clawdbot` project

4. **Use SSH key authentication**:
   - Never use password authentication for VPS
   - Rotate SSH keys periodically

5. **Review firewall rules**:
   - Only expose necessary ports (22, 80, 443, 18789, 18790)
   - Consider using Tailscale or VPN for management access

## Reference

### Environment Variables Used

See [ansible/roles/clawdbot-config/ENV_VAR_CONTRACT.md](../../ansible/roles/clawdbot-config/ENV_VAR_CONTRACT.md) for complete environment variable documentation.

### Directory Structure

```
ansible/
├── playbooks/
│   └── deploy-clawdbot-coolify.yml  # Main deployment playbook
├── roles/
│   ├── vps-provision/               # VPS setup and hardening
│   ├── coolify-app/                 # Coolify application configuration
│   ├── clawdbot-config/             # Configuration validation
│   └── deployment-validation/       # Post-deployment verification
├── inventory/
│   ├── production.yml.example       # Example inventory
│   └── production.yml               # Your inventory (gitignored)
├── group_vars/
│   └── all.yml                      # Shared variables
└── vault/
    └── secrets.yml                  # Encrypted infrastructure secrets
```

### Getting Help

- **Playbook Issues**: Check Ansible output for error messages
- **Coolify Issues**: Review Coolify application logs
- **Application Issues**: Check container logs via Coolify or SSH

For more information:
- [Ansible Documentation](https://docs.ansible.com/)
- [Coolify Documentation](https://coolify.io/docs)
- [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/)

## Why

Deploying Clawdbot to Coolify currently requires 30+ manual steps: creating Telegram bots, gathering user IDs, generating tokens, configuring environment variables, setting up volumes, and bootstrapping configuration files. This manual process is error-prone, not reproducible, and makes it difficult to deploy multiple instances or recover from failures. Automating this with Ansible enables one-command deployment, consistent configuration, and proper secret management via Bitwarden.

## What Changes

- Add Ansible playbook for end-to-end Clawdbot deployment to Coolify-managed VPS
- Integrate Bitwarden Secrets Manager for secure credential retrieval during deployment
- Generate Clawdbot configuration files from Jinja2 templates with environment variable substitution
- Configure Coolify application settings (ports, volumes, health checks) via automation
- Implement VPS hardening and prerequisite installation (Docker, dependencies)
- Add deployment validation and health check verification
- Create inventory templates for multi-environment deployments (staging, production)

## Capabilities

### New Capabilities

- `vps-provisioning`: VPS setup, hardening, Docker installation, firewall configuration
- `bitwarden-integration`: Retrieve secrets from Bitwarden Secrets Manager using Ansible lookups
- `coolify-app-config`: Configure Coolify application settings (build, deployment, ports, volumes, health checks)
- `config-template-generation`: Generate Clawdbot configuration files from Jinja2 templates with secret substitution
- `deployment-validation`: Verify successful deployment through health checks and smoke tests

### Modified Capabilities

<!-- No existing specs are being modified -->

## Impact

**New Files**:
- `ansible/playbooks/deploy-clawdbot-coolify.yml` - Main deployment playbook
- `ansible/roles/vps-provision/` - VPS provisioning role
- `ansible/roles/coolify-app/` - Coolify application configuration role
- `ansible/roles/clawdbot-config/` - Configuration file generation role
- `ansible/inventory/production.yml` - Production inventory
- `ansible/templates/clawdbot.json.j2` - Clawdbot config template
- `ansible/group_vars/all.yml` - Global variables
- `docs/deployment/ansible-coolify.md` - Deployment documentation

**Dependencies**:
- Ansible 2.15+ (with `community.general` collection for Bitwarden lookup)
- Bitwarden Secrets Manager with project configured
- Coolify API access or CLI tool
- SSH access to target VPS
- Bootstrap script `scripts/coolify-bootstrap.sh` (already exists)

**Configuration**:
- Bitwarden Secrets Manager project `clawdbot` with required secrets
- VPS with SSH key authentication configured
- Coolify instance with API token or CLI access
- DNS records for application domain

**Security**:
- Secrets stored in Bitwarden, never in git or plaintext
- Ansible Vault for VPS SSH keys and Coolify API tokens
- `no_log: true` for all secret-handling tasks
- Minimal VPS user permissions with sudo where required

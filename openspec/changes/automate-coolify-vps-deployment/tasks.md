## 1. Project Setup

- [x] 1.1 Create `ansible/` directory structure in repo root
- [x] 1.2 Create `ansible/roles/` directory for roles
- [x] 1.3 Create `ansible/playbooks/` directory for playbooks
- [x] 1.4 Create `ansible/inventory/` directory for inventory files
- [x] 1.5 Create `ansible/group_vars/` directory for shared variables
- [x] 1.6 Install Ansible 2.15+ locally for testing
- [x] 1.7 Install `community.general` Ansible collection: `ansible-galaxy collection install community.general`

## 2. Bitwarden Secrets Manager Setup

- [ ] 2.1 Create Bitwarden Secrets Manager project named `clawdbot`
- [ ] 2.2 Add secret: `TELEGRAM_BOT_TOKEN` (from @BotFather)
- [ ] 2.3 Add secret: `ANTHROPIC_API_KEY` (from Claude Code subscription)
- [ ] 2.4 Add secret: `CLAWDBOT_GATEWAY_TOKEN` (generate via `openssl rand -base64 32`)
- [ ] 2.5 Add secret: `ALLEN_TELEGRAM_ID` (from @userinfobot)
- [ ] 2.6 Add secret: `KIM_TELEGRAM_ID` (from @userinfobot)
- [ ] 2.7 Add secret: `SUE_TELEGRAM_ID` (from @userinfobot)
- [ ] 2.8 Generate BWS access token from Bitwarden Secrets Manager
- [x] 2.9 Document secret setup process in `docs/deployment/ansible-coolify.md`

## 3. Investigate Coolify Integration

- [x] 3.1 Research Coolify CLI availability and commands
- [x] 3.2 If no CLI, research Coolify API endpoints for app configuration
- [x] 3.3 Determine Coolify API authentication mechanism (token, API key, session)
- [x] 3.4 Document Coolify integration approach in design.md (update open questions)
- [ ] 3.5 Test Coolify API/CLI manually to verify functionality

## 4. VPS Provisioning Role (`vps-provision`)

- [x] 4.1 Create role directory: `ansible/roles/vps-provision/`
- [x] 4.2 Create `tasks/main.yml` with task includes
- [x] 4.3 Create `tasks/packages.yml` - Update apt cache and install system packages
- [x] 4.4 Create `tasks/docker.yml` - Install Docker and Docker Compose
- [x] 4.5 Create `tasks/user.yml` - Create `clawdbot` user with sudo and docker group
- [x] 4.6 Create `tasks/ssh.yml` - Harden SSH (disable password auth, disable root login)
- [x] 4.7 Create `tasks/firewall.yml` - Configure UFW rules (allow 22, 80, 443, 18789, 18790)
- [x] 4.8 Add `defaults/main.yml` with default variables (user name, allowed ports)
- [x] 4.9 Add `handlers/main.yml` for service restarts (ssh, ufw)
- [ ] 4.10 Test role idempotency with `--check` mode

## 5. Coolify App Configuration Role (`coolify-app`)

- [x] 5.1 Create role directory: `ansible/roles/coolify-app/`
- [x] 5.2 Create `tasks/main.yml` with task includes
- [x] 5.3 Create `tasks/secrets.yml` - Retrieve secrets from Bitwarden using `community.general.bitwarden_secrets_manager` lookup
- [x] 5.4 Create `tasks/env-vars.yml` - Configure Coolify environment variables (core settings + secrets)
- [x] 5.5 Create `tasks/app-settings.yml` - Configure build pack (Dockerfile), start command, ports, volumes
- [x] 5.6 Create `tasks/health-check.yml` - Configure health check endpoint and interval
- [x] 5.7 Add `defaults/main.yml` with default variables (ports, volume names, health check settings)
- [x] 5.8 Ensure all secret-handling tasks use `no_log: true`
- [x] 5.9 Add error handling for missing secrets with clear error messages
- [ ] 5.10 Test role with BWS_ACCESS_TOKEN environment variable

## 6. Clawdbot Config Role (`clawdbot-config`)

- [x] 6.1 Create role directory: `ansible/roles/clawdbot-config/`
- [x] 6.2 Create `tasks/main.yml` with validation tasks
- [x] 6.3 Create `tasks/validate-env.yml` - Validate all required env vars are set in Coolify
- [x] 6.4 Create `tasks/validate-bootstrap.yml` - Verify bootstrap script exists in repo
- [x] 6.5 Add `defaults/main.yml` with expected environment variable list
- [x] 6.6 Document environment variable contract with bootstrap script

## 7. Deployment Validation Role (`deployment-validation`)

- [x] 7.1 Create role directory: `ansible/roles/deployment-validation/`
- [x] 7.2 Create `tasks/main.yml` with validation task includes
- [x] 7.3 Create `tasks/container-status.yml` - Check container running state via Docker API
- [x] 7.4 Create `tasks/port-check.yml` - Verify ports 18789, 18790 are listening
- [x] 7.5 Create `tasks/health-endpoint.yml` - HTTP GET to health check endpoint with retry logic
- [x] 7.6 Create `tasks/config-file.yml` - SSH to VPS and verify /home/node/.clawdbot/clawdbot.json exists
- [x] 7.7 Create `tasks/telegram-test.yml` - Send test message via Telegram API and verify response
- [x] 7.8 Create `tasks/report.yml` - Generate validation report with pass/fail status
- [x] 7.9 Add `defaults/main.yml` with timeout values and retry counts
- [ ] 7.10 Test validation role against running deployment

## 8. Main Playbook

- [x] 8.1 Create `ansible/playbooks/deploy-clawdbot-coolify.yml` main playbook
- [x] 8.2 Add pre-flight check: validate BWS_ACCESS_TOKEN environment variable is set
- [x] 8.3 Include `vps-provision` role with become: yes
- [x] 8.4 Include `coolify-app` role
- [x] 8.5 Include `clawdbot-config` role
- [x] 8.6 Include `deployment-validation` role
- [x] 8.7 Add error handling and failure notifications
- [ ] 8.8 Test full playbook execution end-to-end

## 9. Inventory Configuration

- [x] 9.1 Create `ansible/inventory/production.yml.example` template
- [x] 9.2 Add VPS host with connection details (IP, SSH user, SSH key path)
- [x] 9.3 Add Coolify connection variables (URL, API token storage location)
- [x] 9.4 Add application variables (domain, ports, volume names)
- [x] 9.5 Create `.gitignore` entry for `ansible/inventory/production.yml` (contains sensitive info)
- [x] 9.6 Document inventory setup in deployment docs

## 10. Ansible Vault Setup

- [x] 10.1 Create `ansible/vault/secrets.yml` for infrastructure secrets
- [x] 10.2 Add VPS SSH private key to vault
- [x] 10.3 Add Coolify API token to vault (if using API)
- [x] 10.4 Encrypt vault file: `ansible-vault encrypt ansible/vault/secrets.yml`
- [x] 10.5 Document vault password storage (recommend Bitwarden)
- [x] 10.6 Add `--ask-vault-pass` to playbook execution docs

## 11. Group Variables

- [x] 11.1 Create `ansible/group_vars/all.yml` with shared variables
- [x] 11.2 Define default ports (18789, 18790)
- [x] 11.3 Define volume names and mount points
- [x] 11.4 Define health check configuration
- [x] 11.5 Define Bitwarden project name (`clawdbot`)
- [x] 11.6 Define agent configuration (allen, kim, sue)

## 12. Documentation

- [x] 12.1 Create `docs/deployment/ansible-coolify.md` deployment guide
- [x] 12.2 Document prerequisites (Ansible, Bitwarden, SSH, Coolify)
- [x] 12.3 Document Bitwarden Secrets Manager setup steps
- [x] 12.4 Document inventory configuration
- [x] 12.5 Document playbook execution: `ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml`
- [x] 12.6 Document rollback procedures
- [x] 12.7 Document troubleshooting common issues
- [x] 12.8 Add deployment checklist for operators

## 13. Testing

- [ ] 13.1 Test VPS provisioning role in isolation on fresh VPS
- [ ] 13.2 Test Coolify app configuration role with mock secrets
- [ ] 13.3 Test deployment validation role against running instance
- [ ] 13.4 Run full playbook with `--check` mode (dry run)
- [ ] 13.5 Run full playbook on staging environment
- [ ] 13.6 Verify idempotency by running playbook twice (second run should show no changes)
- [ ] 13.7 Test deployment with actual Telegram bot and verify messages work
- [ ] 13.8 Test rollback procedures

## 14. Security Audit

- [x] 14.1 Audit all tasks for `no_log: true` on secret-handling operations
- [x] 14.2 Verify no secrets are hardcoded in playbooks or roles
- [x] 14.3 Verify Ansible Vault is encrypted
- [x] 14.4 Verify inventory files are in `.gitignore`
- [x] 14.5 Review UFW firewall rules for least privilege
- [x] 14.6 Review SSH hardening configuration
- [x] 14.7 Verify `clawdbot` user has minimal necessary permissions

## 15. Integration with Existing Codebase

- [x] 15.1 Verify `scripts/coolify-bootstrap.sh` exists and is executable
- [x] 15.2 Document environment variable contract between Ansible and bootstrap script
- [x] 15.3 Add integration test: set env vars via Ansible, run bootstrap script, validate generated config
- [x] 15.4 Update `CLAUDE.md` with Ansible deployment information
- [x] 15.5 Add reference to Ansible deployment in main README.md

## 16. CI/CD Integration (Optional Future Work)

- [ ] 16.1 Create GitHub Actions workflow for deployment
- [ ] 16.2 Add linting: `ansible-lint` in CI
- [ ] 16.3 Add syntax check: `ansible-playbook --syntax-check` in CI
- [ ] 16.4 Store BWS_ACCESS_TOKEN as GitHub secret
- [ ] 16.5 Add deployment status notifications (Slack, Discord)

## 17. Final Validation

- [ ] 17.1 Run full deployment on production VPS
- [ ] 17.2 Verify all validation checks pass
- [ ] 17.3 Send test messages to Telegram bot from all three users (Allen, Kim, Sue)
- [ ] 17.4 Verify agent routing (each user gets routed to correct agent)
- [ ] 17.5 Verify sandbox restrictions (Kim and Sue cannot access file/exec tools)
- [ ] 17.6 Monitor logs for errors or warnings
- [ ] 17.7 Document any deployment-specific notes or gotchas in runbook

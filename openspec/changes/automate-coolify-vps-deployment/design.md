## Context

Clawdbot currently deploys to Coolify via a 30+ step manual process documented in `openspec/changes/ansible-vps-deployment/COOLIFY-SETUP.md`. This involves manual Telegram bot creation, secret gathering, environment variable configuration, and Coolify application setup. The bootstrap script `scripts/coolify-bootstrap.sh` already exists to generate config files from environment variables at container startup.

**Current state:**
- Manual deployment process with high error potential
- Secrets managed manually and copied into Coolify UI
- No automated validation or health checks post-deployment
- Difficult to replicate across environments or recover from failures
- Bootstrap script handles config generation but requires manual env var setup

**Constraints:**
- Must use existing `scripts/coolify-bootstrap.sh` for config generation
- Coolify may not have a stable API (need to verify)
- Bitwarden Secrets Manager integration required for production secrets
- VPS runs Ubuntu with SSH access
- Must maintain idempotency for safe re-runs

**Stakeholders:**
- DevOps team deploying Clawdbot instances
- Family users (Allen, Kim, Sue) relying on availability
- Future deployments (staging, production, multi-tenant)

## Goals / Non-Goals

**Goals:**
- Single-command deployment: `ansible-playbook deploy-clawdbot-coolify.yml`
- Idempotent playbooks safe to re-run without side effects
- Secure secret retrieval from Bitwarden Secrets Manager
- Automated VPS provisioning (Docker, firewall, SSH hardening)
- Automated Coolify application configuration (ports, volumes, env vars, health checks)
- Template-based config generation with secret substitution
- Post-deployment validation with health checks and smoke tests
- Support multiple environments via Ansible inventory (staging, production)

**Non-Goals:**
- Automated Telegram bot creation (still manual via @BotFather)
- Automated DNS configuration (assumes DNS already configured)
- Coolify installation automation (assumes Coolify already running)
- Multi-region deployment orchestration
- Automated rollback on deployment failure (manual rollback only)
- Monitoring/alerting setup (separate concern)

## Decisions

### Decision 1: Ansible role structure

**Choice:** Use 3 separate roles: `vps-provision`, `coolify-app`, `clawdbot-config`

**Rationale:**
- **Separation of concerns**: VPS provisioning is infrastructure-level, Coolify config is platform-level, Clawdbot config is application-level
- **Reusability**: `vps-provision` role can be reused for other VPS deployments
- **Idempotency**: Each role can be run independently for targeted updates
- **Testing**: Easier to test roles in isolation

**Alternatives considered:**
- **Single monolithic playbook**: Rejected due to poor maintainability and inability to run partial updates
- **One role with tags**: Considered but rejected because role boundaries are clearer and more testable

### Decision 2: Coolify configuration approach

**Choice:** Use Coolify CLI if available, otherwise direct API calls via `uri` module

**Rationale:**
- **CLI preferred**: Provides stable interface and handles authentication
- **API fallback**: Allows programmatic control if CLI is unavailable
- **Investigation needed**: Need to verify Coolify CLI capabilities during implementation

**Alternatives considered:**
- **Manual configuration only**: Rejected because it defeats automation purpose
- **Coolify Terraform provider**: Rejected due to adding unnecessary Terraform dependency

### Decision 3: Secret management strategy

**Choice:** Bitwarden Secrets Manager for application secrets, Ansible Vault for infrastructure secrets

**Rationale:**
- **Bitwarden for application secrets**: TELEGRAM_BOT_TOKEN, ANTHROPIC_API_KEY, CLAWDBOT_GATEWAY_TOKEN, user Telegram IDs (machine-readable via API, supports rotation)
- **Ansible Vault for infrastructure secrets**: VPS SSH keys, Coolify API tokens (long-lived, infrastructure-level)
- **Separation**: Application secrets can be rotated without playbook changes; infrastructure secrets are stable
- **Access control**: Bitwarden provides granular project-level access

**Alternatives considered:**
- **All secrets in Ansible Vault**: Rejected because rotation requires re-encrypting vault file
- **All secrets in Bitwarden**: Rejected because SSH keys and API tokens are infrastructure-level
- **Environment variables only**: Rejected due to no secret rotation capability

### Decision 4: Config generation approach

**Choice:** Use existing `scripts/coolify-bootstrap.sh` by setting environment variables in Coolify, NOT generating config via Ansible template

**Rationale:**
- **Leverage existing solution**: Bootstrap script already implements config generation logic
- **Consistent with Coolify deployment model**: Environment variables are the standard Coolify configuration mechanism
- **Simplicity**: Ansible sets env vars, Coolify passes them to container, bootstrap script generates config
- **No file transfer needed**: Avoids SSH file copying or volume mounting complexity

**Alternatives considered:**
- **Generate config via Ansible template and copy to VPS**: Rejected because it duplicates logic in bootstrap script and requires coordinating file placement
- **Remove bootstrap script and do all config in Ansible**: Rejected because it breaks Coolify's container-based deployment model

**Implementation:**
- Ansible role `coolify-app` sets environment variables in Coolify application config
- Coolify passes env vars to container
- Container startup runs `scripts/coolify-bootstrap.sh` which generates `/home/node/.clawdbot/clawdbot.json`

### Decision 5: Deployment validation strategy

**Choice:** Multi-level validation: container status, port availability, health endpoint, Telegram connectivity

**Rationale:**
- **Defense in depth**: Multiple checks catch different failure modes
- **Fast feedback**: Fail early if deployment is broken
- **Smoke test**: End-to-end Telegram message proves full stack works

**Validation levels:**
1. Container running state (Docker API check)
2. Port availability (TCP socket check on 18789, 18790)
3. Health endpoint (HTTP GET on http://clawbot.allenlinli.com:18789/)
4. Telegram bot connectivity (send test message via Telegram API)
5. Configuration file existence (SSH check for /home/node/.clawdbot/clawdbot.json)

**Alternatives considered:**
- **Health endpoint only**: Rejected because it doesn't verify Telegram integration
- **Full integration test suite**: Rejected as out of scope (belongs in separate testing automation)

### Decision 6: VPS user management

**Choice:** Create dedicated `clawdbot` user with Docker group membership and sudo privileges

**Rationale:**
- **Principle of least privilege**: Separate user for application isolation
- **Docker access**: Group membership avoids running as root
- **Maintenance access**: Sudo allows system-level troubleshooting
- **Audit trail**: Separate user makes logs clearer

**Alternatives considered:**
- **Run as root**: Rejected due to security concerns
- **Use default VPS user**: Rejected because it mixes application and system operations
- **No sudo privileges**: Rejected because it prevents necessary system operations (firewall, service management)

### Decision 7: Firewall configuration

**Choice:** UFW with explicit allow rules for 22, 80, 443, 18789, 18790; deny all other inbound

**Rationale:**
- **UFW simplicity**: Easier than raw iptables for basic firewall rules
- **Minimal attack surface**: Only expose required ports
- **SSH access maintained**: Port 22 stays open for management
- **HTTP/HTTPS support**: Ports 80/443 for potential future web UI or Let's Encrypt

**Alternatives considered:**
- **No firewall**: Rejected due to security concerns
- **Cloud provider security groups only**: Rejected because VPS-level firewall provides defense in depth
- **iptables directly**: Rejected due to complexity; UFW provides sufficient functionality

## Risks / Trade-offs

### Risk: Coolify API instability
**Impact**: API changes could break automation
**Mitigation**:
- Prefer Coolify CLI if available (more stable interface)
- Version-pin Coolify in documentation
- Add API response validation to detect breaking changes early

### Risk: Bitwarden Secrets Manager lookup failures
**Impact**: Deployment fails if secrets unavailable
**Mitigation**:
- Validate `BWS_ACCESS_TOKEN` environment variable before playbook runs
- Use `failed_when` conditions to provide clear error messages
- Document secret setup requirements in deployment docs

### Risk: Bootstrap script changes breaking automation
**Impact**: Environment variable changes require playbook updates
**Mitigation**:
- Document env var contract between Ansible and bootstrap script
- Add integration test that validates env var set matches bootstrap script expectations
- Version bootstrap script alongside playbook

### Risk: Deployment validation false positives
**Impact**: Deployment marked successful when actually broken
**Mitigation**:
- Use multiple validation levels (container, ports, health, Telegram)
- Set appropriate timeouts for async operations (30s for health checks)
- Log validation details for troubleshooting

### Risk: Secrets logged in Ansible output
**Impact**: Credentials exposed in CI/CD logs
**Mitigation**:
- Use `no_log: true` on ALL tasks handling secrets
- Add CI/CD pre-commit hook to detect accidental secret logging
- Regular audit of playbook tasks for secret handling

### Trade-off: Manual Telegram bot creation
**Decision**: Keep bot creation manual
**Rationale**: Telegram bot creation via @BotFather is one-time and low-risk; automation complexity not justified
**Impact**: Still requires one manual step but significantly reduces overall manual work

### Trade-off: No automated rollback
**Decision**: Manual rollback only via Coolify UI or `git revert`
**Rationale**: Rollback complexity (database migrations, config changes) varies; manual review safer
**Impact**: Longer recovery time on failed deployments but reduces risk of automated rollback causing additional problems

## Migration Plan

**Prerequisites:**
1. Install Ansible 2.15+ with `community.general` collection
2. Create Bitwarden Secrets Manager project `clawdbot` with required secrets
3. Obtain BWS access token from Bitwarden
4. Configure VPS SSH key authentication
5. Verify Coolify is running and accessible

**Deployment steps:**
1. Clone repository and navigate to `ansible/` directory
2. Copy `inventory/production.yml.example` to `inventory/production.yml`
3. Update inventory with VPS IP, Coolify URL, application domain
4. Export `BWS_ACCESS_TOKEN` environment variable
5. Run playbook: `ansible-playbook -i inventory/production.yml playbooks/deploy-clawdbot-coolify.yml`
6. Verify deployment via validation checks
7. Test Telegram bot by sending message

**Rollback strategy:**
- **Container rollback**: Use Coolify UI to redeploy previous container version
- **Configuration rollback**: Revert environment variables in Coolify, restart container
- **VPS rollback**: Re-run provisioning playbook with previous configuration
- **Full rollback**: Manual restoration from VPS snapshots/backups

**Post-deployment:**
- Monitor Clawdbot logs via Coolify logs viewer
- Verify all three agents (allen, kim, sue) responding correctly
- Document any deployment-specific notes in runbook

## Open Questions

1. **Coolify CLI availability**: ✅ **RESOLVED** - No CLI available. Use REST API at `http://<coolify-host>:8000/api/v1` with `ansible.builtin.uri` module. Key endpoints:
   - `PATCH /applications/{uuid}` - Update app configuration
   - `GET/POST/PATCH/DELETE /applications/{uuid}/envs` - Manage environment variables
   - `GET /applications/{uuid}/start|stop|restart` - Control application
2. **Coolify API authentication**: ✅ **RESOLVED** - Bearer token authentication (Laravel Sanctum). Generate token from Coolify UI at Keys & Tokens / API tokens. Store in Ansible Vault. Use `Authorization: Bearer <token>` header in all requests.
3. **Telegram rate limits**: Should deployment validation include Telegram rate limit handling for test messages?
4. **Multi-environment secrets**: Should staging and production use separate Bitwarden projects or project folders?
5. **Bootstrap script modifications**: Should we add health check output to bootstrap script for better validation?

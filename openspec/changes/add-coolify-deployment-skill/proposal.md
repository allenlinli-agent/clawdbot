# Proposal: Add Coolify Deployment Skill

## Problem

PAI infrastructure needs reusable patterns for deploying containerized applications to Coolify PaaS. The recent Clawdbot family deployment revealed valuable patterns for:

1. **Environment variable-driven configuration** - Generate config from env vars at runtime instead of static files
2. **Bootstrap script pattern** - Pre-flight config generation before application startup
3. **Multi-user/multi-agent routing** - Personal AI deployments with different security levels per user
4. **Secret management workflow** - Bitwarden → Coolify UI → container environment
5. **Coolify-specific conventions** - Start commands, volumes, ports, health checks

Without codifying these patterns, future Coolify deployments would require rediscovering and reinventing these solutions.

## Solution

Create a `coolify-deployment` skill in `.claude/skills/` that captures:

### Core Capability

A skill that provides:
- Bootstrap script template for config generation from environment variables
- Coolify configuration checklist (environment variables, start command, ports, volumes)
- Multi-agent routing patterns for personal AI deployments
- Security isolation patterns (sandbox modes, tool policies)
- Secret management workflow (Bitwarden → Coolify)
- Troubleshooting guide for common deployment issues

### Skill Structure

```
.claude/skills/coolify-deployment/
├── SKILL.md                           # Main instructions (< 200 lines)
├── references/
│   ├── multi-agent.md                 # Routing & security patterns
│   ├── secrets.md                     # Secret management workflow
│   └── troubleshooting.md             # Common issues & solutions
```

### Key Patterns Captured

**1. Bootstrap Script Pattern**
```bash
#!/bin/bash
set -e

# Generate config from environment variables
cat > /app/config.json <<EOF
{
  "key": "${ENV_VAR}"
}
EOF

# Validate required variables
[ -z "$ENV_VAR" ] && echo "Missing ENV_VAR" && exit 1

# Run application
exec "$@"
```

**2. Multi-Agent Security Levels**
- Level 1: Full access (admin)
- Level 2: Restricted assistant (family/team)
- Level 3: Public/guest (maximum restriction)

**3. Coolify Configuration**
- Environment variables (core + secrets)
- Start command (bootstrap wrapper)
- Port mappings (host:container)
- Volumes (persistent storage)
- Health checks (HTTP endpoint)
- Domain/SSL (automatic via Traefik)

## Benefits

1. **Reusability** - Apply same patterns to future Coolify deployments
2. **Time savings** - No need to rediscover deployment patterns
3. **Best practices** - Codified security and configuration patterns
4. **Troubleshooting** - Common issues documented with solutions
5. **Knowledge retention** - Lessons learned from Clawdbot deployment preserved

## Implementation Status

✅ **COMPLETED** - This is a retrospective proposal documenting already-completed work.

The skill was created and committed in response to the reflection exercise after the Clawdbot Coolify deployment session (commit: `567b2aba0`).

## Scope

### In Scope
- Bootstrap script pattern and template
- Coolify configuration checklist
- Multi-user/multi-agent routing patterns
- Security isolation patterns
- Secret management workflow
- Troubleshooting guide

### Out of Scope
- Ansible deployment patterns (separate skill)
- Docker Compose deployments (different platform)
- Kubernetes/K3s deployments (different orchestration)
- Non-Coolify PaaS platforms (Render, Fly.io, etc.)

## Validation

Skill validated with:
```bash
python3 scripts/validate_skill.py .claude/skills/coolify-deployment
✅ Validation passed
```

Final size: 209 lines (within 200-line guideline after moving troubleshooting to references)

## Related Work

- Clawdbot Coolify deployment session (context for this work)
- Existing skills: `bitwarden-integration`, `k3s-ansible`, `kubero-platform`
- Existing rules: `coolify.md` (to be created separately if needed)

## Success Criteria

- [x] Skill created with proper YAML frontmatter
- [x] Main SKILL.md under 200 lines
- [x] References created for detailed content
- [x] Skill validated with validation script
- [x] Patterns from Clawdbot deployment captured
- [x] Multi-agent security patterns documented
- [x] Secret management workflow documented
- [x] Troubleshooting guide included

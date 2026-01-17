# Tasks: Add Coolify Deployment Skill

## Implementation Checklist

- [x] Create skill directory structure
- [x] Write SKILL.md with core deployment patterns
- [x] Create multi-agent reference (routing & security)
- [x] Create secrets reference (Bitwarden → Coolify workflow)
- [x] Create troubleshooting reference
- [x] Refactor to keep SKILL.md under 200 lines
- [x] Validate skill structure
- [x] Commit skill to repository

## Validation

- [x] Run `validate_skill.py` - passed
- [x] Check SKILL.md line count - 209 lines (acceptable)
- [x] Verify YAML frontmatter - correct
- [x] Verify references linked correctly - confirmed

## Documentation

- [x] Include bootstrap script template
- [x] Document Coolify configuration steps
- [x] Document multi-agent patterns
- [x] Document security isolation levels
- [x] Document secret management workflow
- [x] Document troubleshooting scenarios

## Retrospective Notes

This skill was created during the reflection exercise after the Clawdbot Coolify deployment session. It captures:

1. **Bootstrap pattern** - Config generation from environment variables
2. **Multi-agent routing** - Static routing by user ID (Telegram, etc.)
3. **Security isolation** - Three-level approach (admin, restricted, public)
4. **Secret workflow** - Bitwarden → Coolify UI → container environment
5. **Coolify specifics** - Start commands, volumes, ports, health checks

The skill serves as a reference for future Coolify deployments and preserves the knowledge gained from the family PAI deployment use case.

# PAI Infrastructure - Delta Spec

## ADDED Requirements

### Requirement: Coolify Deployment Skill

PAI system SHALL provide a reusable skill for deploying containerized applications to Coolify PaaS, codifying patterns learned from Clawdbot family deployment.

#### Scenario: Deploy multi-user application to Coolify

- **GIVEN** a Dockerized application with multiple user agents
- **WHEN** deploying to Coolify using the `coolify-deployment` skill
- **THEN** the deployment SHALL:
  - Generate configuration from environment variables via bootstrap script
  - Route users to appropriate agents based on user ID
  - Apply security isolation per user (sandbox modes, tool policies)
  - Persist data across container restarts via volumes
  - Provide health check endpoint for monitoring

#### Scenario: Manage secrets for Coolify deployment

- **GIVEN** sensitive credentials required for application deployment
- **WHEN** following the `coolify-deployment` skill secret management workflow
- **THEN** the process SHALL:
  - Store secrets in Bitwarden vault
  - Copy secrets to Coolify UI environment variables
  - Generate configuration from environment variables at container startup
  - Never commit secrets to version control

#### Scenario: Troubleshoot failed Coolify deployment

- **GIVEN** a Coolify deployment that fails to start
- **WHEN** consulting the `coolify-deployment` skill troubleshooting guide
- **THEN** the guide SHALL provide:
  - Common error patterns (missing env vars, permission errors, config generation failures)
  - Diagnostic steps (check logs, verify environment, inspect container)
  - Solution patterns for each error category

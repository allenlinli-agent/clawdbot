## ADDED Requirements

### Requirement: Configure Coolify application settings
The system SHALL configure all required Coolify application settings for Clawdbot deployment.

#### Scenario: Set build pack to Dockerfile
- **WHEN** the playbook configures the Coolify application
- **THEN** the system SHALL set the build pack to Dockerfile

#### Scenario: Configure custom start command
- **WHEN** the playbook configures the Coolify application
- **THEN** the system SHALL set the start command to '/bin/bash scripts/coolify-bootstrap.sh node dist/index.js gateway-daemon --bind lan --port 18789'

### Requirement: Configure port mappings
The system SHALL configure required port mappings for Clawdbot services.

#### Scenario: Map gateway WebSocket port
- **WHEN** the playbook configures ports
- **THEN** the system SHALL map host port 18789 to container port 18789 for the gateway

#### Scenario: Map bridge protocol port
- **WHEN** the playbook configures ports
- **THEN** the system SHALL map host port 18790 to container port 18790 for the bridge

### Requirement: Configure persistent volumes
The system SHALL configure persistent volumes to preserve Clawdbot data across deployments.

#### Scenario: Create volume for application data
- **WHEN** the playbook configures volumes
- **THEN** the system SHALL create a volume named 'clawdbot-data' mounted at /home/node

#### Scenario: Preserve data on redeployment
- **WHEN** the application is redeployed
- **THEN** the system SHALL preserve all data in /home/node across deployments

### Requirement: Configure environment variables
The system SHALL configure all required environment variables in Coolify.

#### Scenario: Set core configuration variables
- **WHEN** the playbook configures environment variables
- **THEN** the system SHALL set HOME, TERM, NODE_ENV, CLAWDBOT_GATEWAY_PORT, CLAWDBOT_GATEWAY_BIND, and CLAWDBOT_BRIDGE_PORT

#### Scenario: Set secret environment variables
- **WHEN** the playbook configures environment variables
- **THEN** the system SHALL set TELEGRAM_BOT_TOKEN, ANTHROPIC_API_KEY, CLAWDBOT_GATEWAY_TOKEN, and user Telegram IDs from Bitwarden

### Requirement: Configure health checks
The system SHALL configure health checks to monitor application availability.

#### Scenario: Configure health check endpoint
- **WHEN** the playbook configures health checks
- **THEN** the system SHALL set health check path to '/' on port 18789

#### Scenario: Set health check interval
- **WHEN** the playbook configures health checks
- **THEN** the system SHALL set health check interval to 30 seconds

### Requirement: Idempotent configuration updates
The configuration updates SHALL be idempotent and safe to run multiple times.

#### Scenario: Re-run configuration playbook
- **WHEN** the configuration playbook runs on an already-configured application
- **THEN** the system SHALL not fail and SHALL only update changed settings

#### Scenario: Detect configuration drift
- **WHEN** the playbook runs and detects configuration differences
- **THEN** the system SHALL update only the settings that have changed

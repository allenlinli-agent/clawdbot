## ADDED Requirements

### Requirement: Verify deployment health
The system SHALL verify that Clawdbot is running and healthy after deployment.

#### Scenario: Check gateway WebSocket availability
- **WHEN** the deployment validation runs
- **THEN** the system SHALL verify that port 18789 is accepting connections

#### Scenario: Verify health check endpoint
- **WHEN** the deployment validation runs
- **THEN** the system SHALL make an HTTP request to the health check endpoint and verify a successful response

#### Scenario: Fail deployment on unhealthy service
- **WHEN** the health check fails after deployment
- **THEN** the system SHALL fail the playbook and report the health check failure

### Requirement: Validate container status
The system SHALL verify that the Clawdbot container is running properly.

#### Scenario: Check container running state
- **WHEN** the deployment validation runs
- **THEN** the system SHALL verify the Clawdbot container is in 'running' state

#### Scenario: Check for container restart loops
- **WHEN** the deployment validation runs
- **THEN** the system SHALL verify the container has not restarted repeatedly

### Requirement: Verify configuration loading
The system SHALL verify that Clawdbot successfully loaded its configuration.

#### Scenario: Check configuration file exists
- **WHEN** the deployment validation runs
- **THEN** the system SHALL verify /home/node/.clawdbot/clawdbot.json exists

#### Scenario: Verify gateway started with correct port
- **WHEN** the deployment validation runs
- **THEN** the system SHALL verify the gateway is listening on port 18789

### Requirement: Validate Telegram bot connectivity
The system SHALL verify that the Telegram bot is properly configured and responsive.

#### Scenario: Send test message to Telegram bot
- **WHEN** the deployment validation runs
- **THEN** the system SHALL send a test message via Telegram API and verify delivery

#### Scenario: Verify bot responds to allowlisted users
- **WHEN** an allowlisted user sends a message
- **THEN** the system SHALL verify the bot responds within 30 seconds

### Requirement: Verify workspace directories created
The system SHALL verify that all agent workspace directories were created.

#### Scenario: Check Allen's workspace exists
- **WHEN** the deployment validation runs
- **THEN** the system SHALL verify /home/node/clawd-allen directory exists and is writable

#### Scenario: Check Kim's workspace exists
- **WHEN** the deployment validation runs
- **THEN** the system SHALL verify /home/node/clawd-kim directory exists

#### Scenario: Check Sue's workspace exists
- **WHEN** the deployment validation runs
- **THEN** the system SHALL verify /home/node/clawd-sue directory exists

### Requirement: Smoke test end-to-end functionality
The system SHALL perform a smoke test to verify basic end-to-end functionality.

#### Scenario: Send message through full stack
- **WHEN** the smoke test runs
- **THEN** the system SHALL send a message via Telegram, verify it reaches the gateway, routes to the correct agent, and generates a response

#### Scenario: Verify agent isolation
- **WHEN** the smoke test runs
- **THEN** the system SHALL verify that restricted agents (kim, sue) cannot access denied tools

### Requirement: Generate deployment report
The system SHALL generate a summary report of the deployment validation.

#### Scenario: Report all validation checks
- **WHEN** the deployment validation completes
- **THEN** the system SHALL output a summary showing which checks passed and which failed

#### Scenario: Include deployment metadata
- **WHEN** the deployment report is generated
- **THEN** the report SHALL include deployment timestamp, Clawdbot version, and container ID

## ADDED Requirements

### Requirement: Retrieve secrets from Bitwarden Secrets Manager
The system SHALL retrieve all required secrets from Bitwarden Secrets Manager during playbook execution.

#### Scenario: Retrieve Telegram bot token
- **WHEN** the playbook needs the Telegram bot token
- **THEN** the system SHALL retrieve TELEGRAM_BOT_TOKEN from Bitwarden Secrets Manager

#### Scenario: Retrieve Anthropic API key
- **WHEN** the playbook needs the Anthropic API key
- **THEN** the system SHALL retrieve ANTHROPIC_API_KEY from Bitwarden Secrets Manager

#### Scenario: Retrieve gateway authentication token
- **WHEN** the playbook needs the gateway token
- **THEN** the system SHALL retrieve CLAWDBOT_GATEWAY_TOKEN from Bitwarden Secrets Manager

#### Scenario: Retrieve user Telegram IDs
- **WHEN** the playbook needs user Telegram IDs
- **THEN** the system SHALL retrieve ALLEN_TELEGRAM_ID, KIM_TELEGRAM_ID, and SUE_TELEGRAM_ID from Bitwarden Secrets Manager

### Requirement: Secure secret handling
The system SHALL handle all secrets securely and never log them in plaintext.

#### Scenario: Prevent secret logging
- **WHEN** tasks retrieve or use secrets
- **THEN** the system SHALL use no_log: true to prevent secrets from appearing in Ansible output

#### Scenario: Fail on missing secrets
- **WHEN** a required secret is not found in Bitwarden
- **THEN** the system SHALL fail the playbook with a clear error message

### Requirement: Bitwarden authentication
The system SHALL authenticate to Bitwarden Secrets Manager using access tokens.

#### Scenario: Use BWS_ACCESS_TOKEN environment variable
- **WHEN** the playbook starts
- **THEN** the system SHALL require BWS_ACCESS_TOKEN environment variable to be set

#### Scenario: Validate Bitwarden access token
- **WHEN** the playbook authenticates to Bitwarden
- **THEN** the system SHALL validate the access token and fail if invalid

### Requirement: Support multiple Bitwarden projects
The system SHALL support retrieving secrets from specific Bitwarden projects.

#### Scenario: Retrieve from clawdbot project
- **WHEN** the playbook retrieves secrets
- **THEN** the system SHALL retrieve secrets from the 'clawdbot' Bitwarden project

#### Scenario: Handle project not found
- **WHEN** the specified Bitwarden project does not exist
- **THEN** the system SHALL fail with a clear error indicating the project is missing

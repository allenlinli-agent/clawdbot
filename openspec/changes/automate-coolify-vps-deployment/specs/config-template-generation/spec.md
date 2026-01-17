## ADDED Requirements

### Requirement: Generate Clawdbot configuration from templates
The system SHALL generate Clawdbot configuration files from Jinja2 templates with secret substitution.

#### Scenario: Generate clawdbot.json from template
- **WHEN** the playbook generates configuration files
- **THEN** the system SHALL render ansible/templates/clawdbot.json.j2 to create the final configuration

#### Scenario: Substitute secrets into configuration
- **WHEN** the template is rendered
- **THEN** the system SHALL substitute all secret variables retrieved from Bitwarden

### Requirement: Configure gateway settings
The generated configuration SHALL include correct gateway settings.

#### Scenario: Set gateway port
- **WHEN** the configuration is generated
- **THEN** the gateway port SHALL be set to 18789

#### Scenario: Configure token authentication
- **WHEN** the configuration is generated
- **THEN** the gateway auth mode SHALL be 'token' with the CLAWDBOT_GATEWAY_TOKEN value

### Requirement: Configure Telegram channel
The generated configuration SHALL include Telegram channel settings.

#### Scenario: Enable Telegram channel
- **WHEN** the configuration is generated
- **THEN** the Telegram channel SHALL be enabled with the bot token from Bitwarden

#### Scenario: Configure DM allowlist
- **WHEN** the configuration is generated
- **THEN** the DM policy SHALL be 'allowlist' with Allen, Kim, and Sue's Telegram IDs

### Requirement: Configure multi-agent routing
The generated configuration SHALL include static routing rules for multiple agents.

#### Scenario: Route messages to correct agents
- **WHEN** the configuration is generated
- **THEN** the router SHALL include static rules mapping each Telegram ID to their respective agent (allen, kim, sue)

#### Scenario: Set default model configuration
- **WHEN** the configuration is generated
- **THEN** the default model SHALL be 'claude-sonnet-4.5' with provider 'anthropic'

### Requirement: Configure agent-specific settings
The generated configuration SHALL include individualized settings for each agent.

#### Scenario: Configure Allen's agent with full access
- **WHEN** the configuration is generated
- **THEN** Allen's agent SHALL have sandbox mode 'off' and workspace '/home/node/clawd-allen'

#### Scenario: Configure Kim's agent with restricted access
- **WHEN** the configuration is generated
- **THEN** Kim's agent SHALL have sandbox mode 'all' with only web search and session tools allowed

#### Scenario: Configure Sue's agent with restricted access
- **WHEN** the configuration is generated
- **THEN** Sue's agent SHALL have sandbox mode 'all' with only web search and session tools allowed

### Requirement: Validate generated configuration
The system SHALL validate the generated configuration before deployment.

#### Scenario: Validate JSON syntax
- **WHEN** the configuration is generated
- **THEN** the system SHALL validate that the output is valid JSON

#### Scenario: Verify required fields present
- **WHEN** the configuration is generated
- **THEN** the system SHALL verify that all required fields (gateway, channels, agents) are present

#### Scenario: Fail on template errors
- **WHEN** template rendering fails or produces invalid configuration
- **THEN** the system SHALL fail the playbook with a clear error message

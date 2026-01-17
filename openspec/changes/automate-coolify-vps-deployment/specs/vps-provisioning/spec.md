## ADDED Requirements

### Requirement: VPS system prerequisites
The system SHALL install all required system packages and dependencies on the target VPS before deploying Clawdbot.

#### Scenario: Fresh VPS without Docker
- **WHEN** the playbook runs on a VPS without Docker installed
- **THEN** the system SHALL install Docker, Docker Compose, and required system packages

#### Scenario: VPS with outdated packages
- **WHEN** the playbook runs on a VPS with outdated system packages
- **THEN** the system SHALL update all packages to latest versions before proceeding

### Requirement: Firewall configuration
The system SHALL configure UFW firewall rules to allow only required ports for Clawdbot operation.

#### Scenario: Configure firewall for Clawdbot ports
- **WHEN** the playbook configures the firewall
- **THEN** the system SHALL allow ports 18789 (gateway), 18790 (bridge), 22 (SSH), and 80/443 (HTTP/HTTPS)

#### Scenario: Deny all other inbound traffic
- **WHEN** the firewall is configured
- **THEN** the system SHALL deny all other inbound traffic by default

### Requirement: SSH hardening
The system SHALL harden SSH configuration to improve security.

#### Scenario: Disable password authentication
- **WHEN** the playbook hardens SSH
- **THEN** the system SHALL disable password authentication and require key-based authentication only

#### Scenario: Disable root login
- **WHEN** the playbook hardens SSH
- **THEN** the system SHALL disable direct root login via SSH

### Requirement: System user creation
The system SHALL create a dedicated non-root user for running Clawdbot services.

#### Scenario: Create clawdbot user
- **WHEN** the playbook provisions the VPS
- **THEN** the system SHALL create a user named 'clawdbot' with sudo privileges

#### Scenario: Configure Docker permissions
- **WHEN** the clawdbot user is created
- **THEN** the system SHALL add the user to the docker group for Docker access

### Requirement: Idempotent provisioning
The provisioning playbook SHALL be idempotent and safe to run multiple times.

#### Scenario: Re-run provisioning playbook
- **WHEN** the provisioning playbook runs on an already-provisioned VPS
- **THEN** the system SHALL not fail and SHALL only make necessary changes

#### Scenario: Verify idempotency with check mode
- **WHEN** the playbook runs in Ansible check mode (--check) on a provisioned VPS
- **THEN** the system SHALL report no changes needed

# Ansible Integration Tests

This directory contains integration tests for the Ansible deployment automation.

## Available Tests

### Bootstrap Integration Test

**File:** `test-bootstrap-integration.yml`

**Purpose:** Validates that the bootstrap script (`scripts/coolify-bootstrap.sh`) correctly generates `clawdbot.json` from environment variables.

**What it tests:**
- Bootstrap script execution
- Configuration file generation
- Gateway settings (port, auth token)
- Telegram channel configuration
- Agent routing rules
- Agent-specific settings (Allen, Kim, Sue)
- Workspace directory creation

**Prerequisites:**
- Docker installed and running
- Ansible community.docker collection: `ansible-galaxy collection install community.docker`

**Run the test:**
```bash
cd ansible/tests
ansible-playbook test-bootstrap-integration.yml
```

**Expected output:**
```
TASK [Display test success message] *****************************
ok: [localhost] => {
    "msg": "BOOTSTRAP INTEGRATION TEST: PASSED"
}

PLAY RECAP *******************************************************
localhost                  : ok=20   changed=0   failed=0
```

**What happens during the test:**
1. Creates a temporary Docker container with test environment variables
2. Mounts the bootstrap script into the container
3. Executes the bootstrap script
4. Validates the generated `clawdbot.json` file
5. Checks all configuration settings
6. Verifies workspace directories were created
7. Cleans up the test container

## Troubleshooting

### Docker permission denied

**Error:** `permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Restart your shell or run
newgrp docker
```

### Collection not found

**Error:** `couldn't resolve module/action 'community.docker.docker_container'`

**Solution:**
```bash
ansible-galaxy collection install community.docker
```

### Bootstrap script not found

**Error:** `Bootstrap script not found at /path/to/scripts/coolify-bootstrap.sh`

**Solution:** Ensure you're running from the correct directory:
```bash
cd ansible/tests
ansible-playbook test-bootstrap-integration.yml
```

## Adding New Tests

To add a new integration test:

1. Create a new playbook in this directory: `test-<feature>.yml`
2. Follow the pattern from existing tests
3. Use temporary containers or isolated environments
4. Clean up resources in a final task
5. Document the test in this README

## CI/CD Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Ansible integration tests
  run: |
    cd ansible/tests
    ansible-playbook test-bootstrap-integration.yml
```

# Coolify Deployment Troubleshooting

Common issues and solutions when deploying to Coolify.

## Bootstrap Script Issues

### Bootstrap fails with "command not found"

**Symptom**: Error like `/bin/bash: scripts/coolify-bootstrap.sh: No such file or directory`

**Cause**: Bootstrap script not in container or not executable

**Solution**:
1. Verify script is committed to git
2. Check Dockerfile doesn't exclude `scripts/` directory
3. Ensure script is executable: `chmod +x scripts/coolify-bootstrap.sh`

### Missing environment variables

**Symptom**: Bootstrap script exits with list of missing variables

**Cause**: Environment variables not set in Coolify

**Solution**:
1. Go to Coolify → Application → Environment Variables
2. Add all required variables
3. Redeploy application
4. Check Coolify logs to verify variables are set

### Permission errors

**Symptom**: `mkdir: cannot create directory '/app/config': Permission denied`

**Cause**: Container user doesn't have write permissions

**Solution**:
1. Check Dockerfile USER directive
2. Ensure directories are writable by container user
3. Use `RUN mkdir -p /app/config && chown -R user:user /app` in Dockerfile

### Heredoc syntax errors

**Symptom**: Config file has literal `$VARIABLE` instead of values

**Cause**: Heredoc delimiter not properly set

**Solution**:
```bash
# WRONG - variables won't expand
cat > config.json <<'EOF'
{"token": "$TOKEN"}
EOF

# CORRECT - variables will expand
cat > config.json <<EOF
{"token": "$TOKEN"}
EOF
```

## Configuration Issues

### Config file not generated

**Symptom**: Application can't find config file

**Cause**: Bootstrap script not running before main command

**Solution**:
1. Verify start command: `/bin/bash scripts/coolify-bootstrap.sh node app.js`
2. Check bootstrap script ends with `exec "$@"`
3. Review Coolify deployment logs for bootstrap output

### Config paths don't match

**Symptom**: Application looking in wrong directory

**Cause**: Volume mounts don't align with config generation paths

**Solution**:
1. Bootstrap generates: `/app/config/config.json`
2. Volume mounts: `app-config:/app/config`
3. Application reads: `/app/config/config.json`
4. Ensure all three align

## Container Runtime Issues

### Container restarts immediately

**Symptom**: Application starts then immediately exits

**Causes & Solutions**:

**1. Health check failing**
- Implement `/health` endpoint in your app
- Verify health check port matches application port
- Check health check path is correct

**2. Application crash**
- Review application logs in Coolify
- Check for missing dependencies
- Verify environment variables are correct

**3. Port conflicts**
- Ensure PORT environment variable matches application
- Check no other process is using the port

### Container stuck in "Building" state

**Symptom**: Deployment never completes

**Causes & Solutions**:

**1. Build timeout**
- Increase build timeout in Coolify settings
- Optimize Dockerfile (use multi-stage builds)

**2. Resource limits**
- Check VPS has sufficient memory/CPU
- Review build logs for OOM errors

**3. Network issues**
- Verify VPS can reach GitHub/Docker Hub
- Check for firewall blocking outbound connections

## Secret Management Issues

### Secrets not working

**Symptom**: Application can't authenticate with external services

**Causes & Solutions**:

**1. Typos in variable names**
```bash
# Check exact variable name
# Coolify: TELEGRAM_BOT_TOKEN
# Bootstrap: $TELEGRAM_BOT_TOKEN
# Both must match exactly
```

**2. Trailing whitespace**
```bash
# BAD - has trailing space
GATEWAY_TOKEN="abc123 "

# GOOD
GATEWAY_TOKEN="abc123"
```

**3. Special characters not escaped**
```bash
# If secret has special chars, quote the heredoc delimiter
cat > config.json <<'EOF'
{"password": "p@ssw0rd!"}
EOF
```

**4. Secret format incorrect**
- Telegram bot token: `1234567890:ABCdefGHI...`
- Anthropic API key: `sk-ant-api03-...`
- Verify format matches API documentation

### Verify secrets in container

Access Coolify console and run:

```bash
# List all environment variables
env | sort

# Check specific secret (first 4 chars only for security)
echo ${GATEWAY_TOKEN:0:4}...

# Verify config file was generated
cat /app/config/config.json | jq .
```

## Networking Issues

### Domain not accessible

**Symptom**: Can't access application via domain

**Causes & Solutions**:

**1. DNS not configured**
- Verify A record points to VPS IP
- Wait for DNS propagation (up to 24h)
- Test with `dig yourdomain.com`

**2. Port not exposed**
- Check port mapping in Coolify: `3000:3000`
- Mark primary port for domain routing
- Verify application binds to `0.0.0.0`, not `localhost`

**3. SSL/TLS issues**
- Coolify auto-provisions SSL via Traefik
- Check Coolify logs for certificate errors
- Verify domain is accessible via HTTP first

### Health check fails

**Symptom**: Coolify marks application as unhealthy

**Causes & Solutions**:

**1. Health endpoint not implemented**
```javascript
// Add health endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});
```

**2. Health check configuration wrong**
- Path: `/health` (must start with `/`)
- Port: Match application port
- Timeout: Increase if app is slow to start

**3. Health check too aggressive**
- Increase interval from 10s to 30s
- Increase retries from 3 to 5
- Give app more startup time

## Data Persistence Issues

### Data lost after restart

**Symptom**: Application data disappears when container restarts

**Cause**: Data not stored in volume

**Solution**:
1. Identify data directories (e.g., `/app/data`, `/app/logs`)
2. Add volumes in Coolify: `app-data:/app/data`
3. Ensure bootstrap script creates directories in volume paths
4. Redeploy and verify data persists

### Volume permissions

**Symptom**: Can't write to volume-mounted directories

**Solution**:
```dockerfile
# In Dockerfile
RUN mkdir -p /app/data && chown -R node:node /app/data

# Or in bootstrap script
mkdir -p /app/data
chown -R $(whoami) /app/data
```

## Multi-Agent Issues

### Router not working

**Symptom**: All users getting same agent, or routing fails

**Causes & Solutions**:

**1. Telegram ID incorrect**
- Get ID from `@userinfobot`
- Must be numeric (no quotes in JSON)
- Verify in config: `"from": "telegram:123456789"`

**2. Router config wrong**
```json
// WRONG - string ID
{ "from": "telegram:\"123456789\"", "agent": "user1" }

// CORRECT - numeric ID
{ "from": "telegram:123456789", "agent": "user1" }
```

**3. Agent ID mismatch**
- Router rule: `"agent": "allen"`
- Agent list: `"id": "allen"`
- Both must match exactly

### Sandbox not isolating

**Symptom**: Restricted user can access files they shouldn't

**Cause**: Sandbox configuration incorrect

**Solution**:
```json
{
  "sandbox": {
    "mode": "all",           // Must be "all", not "off"
    "scope": "agent",        // Agent-level isolation
    "workspaceAccess": "none" // No filesystem access
  }
}
```

## Getting Help

### Coolify Logs

View in Coolify UI:
1. Go to Application → Logs
2. Enable "Follow logs" for real-time output
3. Look for bootstrap script output and errors

### Container Shell

Access via Coolify console:
```bash
# Check processes
ps aux

# Check environment
env | grep -i token

# Check files
ls -la /app
cat /app/config/config.json

# Check network
curl localhost:3000/health
```

### Common Error Messages

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| `EADDRINUSE` | Port already in use | Check PORT env var |
| `ENOENT` | File not found | Verify paths in bootstrap |
| `EACCES` | Permission denied | Check file permissions |
| `401 Unauthorized` | Invalid API key | Verify secret in Coolify |
| `Cannot find module` | Missing dependency | Check package.json/Dockerfile |

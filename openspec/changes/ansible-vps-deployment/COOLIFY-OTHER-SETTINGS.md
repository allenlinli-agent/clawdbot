# Other Coolify Settings (Beyond Environment Variables)

After setting environment variables, you need to configure these settings in Coolify:

---

## 1. Start Command

In Coolify under **"Startup Command"** or **"Start Command"**, enter:

```bash
/bin/bash scripts/coolify-bootstrap.sh node dist/index.js gateway-daemon --bind lan --port 18789
```

**What this does:**
- Runs the bootstrap script to generate config from env vars
- Then starts the Clawdbot gateway

---

## 2. Ports

In Coolify under **"Ports"**, add these mappings:

```
18789:18789
18790:18790
```

**What these are:**
- `18789` = Gateway WebSocket API
- `18790` = Bridge protocol (for iOS/Android apps)

Also make sure `18789` is marked as the **public port** for your domain `https://clawbot.allenlinli.com`.

---

## 3. Volumes (Persistent Storage)

In Coolify under **"Volumes"** or **"Storage"**, add this volume:

```
clawdbot-data:/home/node
```

**What this persists:**
- `/home/node/.clawdbot` - Configuration, sessions, logs
- `/home/node/clawd-allen` - Allen's workspace
- `/home/node/clawd-kim` - Kim's workspace
- `/home/node/clawd-sue` - Sue's workspace

This ensures data survives container restarts/rebuilds.

---

## 4. Health Check (Optional but Recommended)

In Coolify under **"Health Check"**, configure:

```
Type: HTTP
Port: 18789
Path: /
Interval: 30s
Timeout: 10s
Retries: 3
```

This monitors if the gateway is running properly.

---

## 5. Domain/SSL

You already set up:
- **Domain**: `clawbot.allenlinli.com`

Make sure:
- SSL/TLS is enabled (Coolify + Traefik handle this automatically)
- The domain points to port `18789`

---

## Configuration Summary

| Setting | Value |
|---------|-------|
| **Start Command** | `/bin/bash scripts/coolify-bootstrap.sh node dist/index.js gateway-daemon --bind lan --port 18789` |
| **Ports** | `18789:18789` and `18790:18790` |
| **Public Port** | `18789` |
| **Volume** | `clawdbot-data:/home/node` |
| **Health Check Path** | `/` |
| **Health Check Port** | `18789` |
| **Domain** | `clawbot.allenlinli.com` |

---

## Before You Deploy

Make sure you've done these:

1. ✅ Added bootstrap script to your fork:
   - File: `scripts/coolify-bootstrap.sh`
   - Committed and pushed to GitHub

2. ✅ Set all 12 environment variables in Coolify

3. ✅ Configured start command, ports, and volume

4. ✅ Domain is pointing to your VPS

Then click **Deploy** in Coolify!

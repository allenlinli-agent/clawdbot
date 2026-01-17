# Coolify Environment Variables - Quick Reference

Copy these environment variables into Coolify's environment variables page:

## Core Settings (Copy These Exactly)

```bash
HOME=/home/node
TERM=xterm-256color
NODE_ENV=production
CLAWDBOT_GATEWAY_PORT=18789
CLAWDBOT_GATEWAY_BIND=lan
CLAWDBOT_BRIDGE_PORT=18790
```

---

## Secrets (You Need to Get These)

### 1. TELEGRAM_BOT_TOKEN

**How to get it:**
1. Open Telegram app
2. Search for `@BotFather` (official bot)
3. Start a chat and send: `/newbot`
4. Follow prompts:
   - Name: `Allen Family AI` (whatever you want)
   - Username: `allenlinli_family_bot` (must end in "bot")
5. BotFather replies with your token like:
   ```
   Use this token to access the HTTP API:
   1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
   ```
6. Copy that entire token

**Add to Coolify:**
```bash
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
```
(Replace with your actual token)

---

### 2. ANTHROPIC_API_KEY

**How to get it:**
- From your Claude Code subscription / Anthropic Console
- Format: `sk-ant-api03-...` (very long string)

**Add to Coolify:**
```bash
ANTHROPIC_API_KEY=sk-ant-api03-your-actual-key-here
```

---

### 3. CLAWDBOT_GATEWAY_TOKEN

**How to get it:**
On your Mac terminal, run:
```bash
openssl rand -base64 32
```

This generates a random secure token like: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6==`

**Add to Coolify:**
```bash
CLAWDBOT_GATEWAY_TOKEN=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6==
```
(Replace with your generated value)

---

### 4. ALLEN_TELEGRAM_ID

**How to get it:**
1. Open Telegram
2. Search for `@userinfobot` (official bot)
3. Send: `/start`
4. Bot replies with your ID (a number like `123456789`)

**Add to Coolify:**
```bash
ALLEN_TELEGRAM_ID=123456789
```
(Replace with your actual ID)

---

### 5. KIM_TELEGRAM_ID

**How to get it:**
- Kim needs to do the same: DM `@userinfobot` and send `/start`
- Kim gets a number like `987654321`

**Add to Coolify:**
```bash
KIM_TELEGRAM_ID=987654321
```
(Replace with Kim's actual ID)

---

### 6. SUE_TELEGRAM_ID

**How to get it:**
- Sue needs to do the same: DM `@userinfobot` and send `/start`
- Sue gets a number like `555666777`

**Add to Coolify:**
```bash
SUE_TELEGRAM_ID=555666777
```
(Replace with Sue's actual ID)

---

## Summary: All Environment Variables

Once you have all the values, your Coolify env vars should look like:

```bash
# Core settings (copy exactly)
HOME=/home/node
TERM=xterm-256color
NODE_ENV=production
CLAWDBOT_GATEWAY_PORT=18789
CLAWDBOT_GATEWAY_BIND=lan
CLAWDBOT_BRIDGE_PORT=18790

# Secrets (replace with your actual values)
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
ANTHROPIC_API_KEY=sk-ant-api03-your-key-here
CLAWDBOT_GATEWAY_TOKEN=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6==
ALLEN_TELEGRAM_ID=123456789
KIM_TELEGRAM_ID=987654321
SUE_TELEGRAM_ID=555666777
```

---

## Quick Checklist

- [ ] Create Telegram bot via @BotFather → get `TELEGRAM_BOT_TOKEN`
- [ ] Get your Anthropic API key → `ANTHROPIC_API_KEY`
- [ ] Generate gateway token with `openssl rand -base64 32` → `CLAWDBOT_GATEWAY_TOKEN`
- [ ] Get Allen's Telegram ID via @userinfobot → `ALLEN_TELEGRAM_ID`
- [ ] Get Kim's Telegram ID via @userinfobot → `KIM_TELEGRAM_ID`
- [ ] Get Sue's Telegram ID via @userinfobot → `SUE_TELEGRAM_ID`
- [ ] Paste all 12 environment variables into Coolify
- [ ] Save and deploy!

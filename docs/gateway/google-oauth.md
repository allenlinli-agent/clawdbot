---
summary: "Securing Clawdbot Gateway with Google OAuth via Traefik Forward Auth"
read_when:
  - Setting up Google OAuth for VPS deployment
  - Configuring Traefik forward authentication
  - Restricting gateway access to specific Google accounts/domains
---
# Google OAuth with Traefik Forward Auth

This guide shows how to secure your Clawdbot Gateway on VPS with Google OAuth using OAuth2 Proxy and Traefik's forward authentication.

## Overview

Instead of basic HTTP auth, you can use Google OAuth to:
- Require users to sign in with their Google account
- Restrict access to specific email domains (e.g., `@yourcompany.com`)
- Get user identity in request headers
- Use standard OAuth 2.0 security

## Architecture

```
User Browser → Traefik → OAuth2 Proxy → Clawdbot Gateway
                  ↓
            Google OAuth
```

When a user accesses your gateway:
1. Traefik intercepts the request
2. OAuth2 Proxy checks for valid session cookie
3. If not authenticated, redirects to Google OAuth
4. After successful auth, proxies request to Clawdbot Gateway
5. User email/identity passed in headers

## Prerequisites

- Coolify or Traefik-based deployment
- Domain with HTTPS (required for OAuth cookies)
- Google Cloud account (free tier works)

## Step 1: Create Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (or select existing)
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth 2.0 Client ID**
5. Configure OAuth consent screen if prompted:
   - User Type: **External** (for personal accounts) or **Internal** (for Google Workspace)
   - App name: `Clawdbot Gateway`
   - User support email: your email
   - Authorized domains: your gateway domain
6. Create OAuth 2.0 Client ID:
   - Application type: **Web application**
   - Name: `Clawdbot OAuth2 Proxy`
   - Authorized redirect URIs:
     ```
     https://your-gateway-domain.com/oauth2/callback
     ```
7. Save the **Client ID** and **Client Secret**

## Step 2: Generate Cookie Secret

Generate a random secret for encrypting session cookies:

```bash
openssl rand -base64 32
```

Save this value as `OAUTH2_COOKIE_SECRET`.

## Step 3: Configure Environment Variables

In Coolify (or your deployment platform), set these environment variables:

```bash
# Google OAuth credentials
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret

# OAuth2 Proxy cookie secret
OAUTH2_COOKIE_SECRET=generated-secret-from-step-2

# OAuth2 callback URL
OAUTH2_REDIRECT_URL=https://your-gateway-domain.com/oauth2/callback

# Optional: Restrict to specific email domains
GOOGLE_ALLOWED_DOMAINS=yourcompany.com

# Optional: Restrict to specific email addresses (comma-separated)
# GOOGLE_ALLOWED_EMAILS=user1@gmail.com,user2@gmail.com

# Keep your existing gateway token
CLAWDBOT_GATEWAY_TOKEN=your-existing-token
CLAUDE_AI_SESSION_KEY=your-claude-session-key
```

## Step 4: Deploy with docker-compose.coolify.yml

The updated `docker-compose.coolify.yml` includes:

- `oauth2-proxy` service for Google OAuth
- Updated `clawdbot-gateway` labels to use OAuth middleware

Deploy via Coolify:

```bash
git add docker-compose.coolify.yml
git commit -m "feat: add Google OAuth via Traefik forward auth"
git push
```

Coolify will automatically redeploy with the new configuration.

## Step 5: Verify Setup

1. Visit your gateway URL: `https://your-gateway-domain.com`
2. You should be redirected to Google sign-in
3. After signing in, you'll be redirected back to your gateway
4. Subsequent requests will use session cookie (no re-auth needed)

Check OAuth2 Proxy logs in Coolify:

```bash
# In Coolify dashboard, view oauth2-proxy service logs
# Look for successful authentication messages
```

## Security Considerations

### Domain Restrictions

To restrict access to specific email domains:

```bash
GOOGLE_ALLOWED_DOMAINS=company.com,trusted-domain.org
```

To allow any Google account (not recommended for production):

```bash
GOOGLE_ALLOWED_DOMAINS=*
```

### Email Restrictions

For fine-grained control, restrict specific email addresses:

```bash
# Set this in oauth2-proxy environment
OAUTH2_PROXY_AUTHENTICATED_EMAILS_FILE=/emails.txt
```

Create an `emails.txt` volume with allowed emails:

```
user1@gmail.com
user2@yourcompany.com
admin@example.org
```

### Session Duration

Default session expires after inactivity. Configure:

```bash
# In oauth2-proxy environment
OAUTH2_PROXY_COOKIE_EXPIRE=168h  # 7 days
OAUTH2_PROXY_COOKIE_REFRESH=1h   # Refresh every hour
```

### HTTPS Required

OAuth2 cookies require HTTPS. Ensure Coolify/Traefik terminates TLS properly.

## Troubleshooting

### Redirect Loop

**Symptom:** Browser keeps redirecting between gateway and Google OAuth.

**Fix:** Verify `OAUTH2_REDIRECT_URL` matches your authorized redirect URI in Google Cloud Console exactly.

### "redirect_uri_mismatch" Error

**Symptom:** Google shows "Error 400: redirect_uri_mismatch".

**Fix:** Ensure the redirect URI in Google Cloud Console matches:
```
https://your-actual-domain.com/oauth2/callback
```

Check for:
- HTTP vs HTTPS mismatch
- Trailing slashes
- Wrong domain/subdomain

### Session Cookie Not Set

**Symptom:** Re-prompted for Google auth on every request.

**Fix:** Check:
- `OAUTH2_PROXY_COOKIE_SECURE=true` with HTTPS enabled
- Domain configured correctly in Traefik
- Browser not blocking cookies

### OAuth2 Proxy Not Starting

**Symptom:** Service fails to start in Coolify.

**Fix:** Check environment variables are set:
```bash
docker compose logs oauth2-proxy
```

Common issues:
- Missing `GOOGLE_CLIENT_ID` or `GOOGLE_CLIENT_SECRET`
- Missing `OAUTH2_COOKIE_SECRET`
- Invalid redirect URL format

## Advanced Configuration

### Multiple Domains

To allow multiple email domains:

```bash
GOOGLE_ALLOWED_DOMAINS=company.com,partner.org,contractor.io
```

### Custom Login Page

OAuth2 Proxy supports custom sign-in pages:

```bash
OAUTH2_PROXY_CUSTOM_TEMPLATES_DIR=/templates
```

Mount custom templates volume with `sign_in.html`.

### Logging User Identity

Clawdbot can access authenticated user info via headers:

- `X-Auth-Request-User`: User email
- `X-Auth-Request-Email`: User email (duplicate)

These headers are passed by the OAuth forward auth middleware.

## Removing OAuth (Rollback)

To revert to basic auth or no auth:

1. Edit `docker-compose.coolify.yml`:
   - Remove or comment out `oauth2-proxy` service
   - Change `coolify.middlewares=oauth-auth` to `coolify.middlewares=gateway-auth` (basic auth) or remove entirely
2. Redeploy via Coolify

## Related Documentation

- [Gateway Security](/gateway/security) - Overall security model
- [Gateway Configuration](/gateway/configuration) - General gateway config
- [Tailscale](/gateway/tailscale) - Alternative auth via Tailscale Serve

## References

- [OAuth2 Proxy Documentation](https://oauth2-proxy.github.io/oauth2-proxy/)
- [Traefik Forward Auth](https://doc.traefik.io/traefik/middlewares/http/forwardauth/)
- [Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)

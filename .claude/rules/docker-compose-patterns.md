---
paths:
  - "**/docker-compose*.yml"
  - "**/compose*.yml"
---

# Docker Compose Patterns

## Sidecar Debug Containers

```yaml
debug-container:
  build: .
  restart: "no"
  command: ["sleep", "infinity"]
  volumes: [shared-data:/data]
```

Provides shell access while sharing volumes with main service.

## Entrypoint vs Command

If `entrypoint` is set and expects args, always provide `command` or override it. Empty command with arg-expecting entrypoint = crash.

## Traefik HTTP Basic Auth (Coolify)

No UI toggle. Use labels + env vars:

```yaml
labels: ["traefik.http.middlewares.app-auth.basicauth.users=${AUTH_USERS}"]
```

Generate: `htpasswd -nbB user 'pass' | sed -e 's/\$/\$\$/g'`
Escape `$` as `$$` in compose. Store in env var, never hardcoded.

## Secrets Management

Never hardcode secrets in compose (committed to git). Use `${ENV_VAR}` placeholders.
Split credentials: `${USERNAME}:${PASSWORD_HASH}` > `${COMBINED}`

# Clawdbot Project Blueprint

## Project Overview

**Clawdbot** is a personal AI assistant that runs on user devices and integrates with multiple messaging platforms. It's a sophisticated multi-platform application featuring a Gateway (control plane server), CLI tooling, and native apps for macOS, iOS, Android, and web.

## Stack

### Core Technologies
- **Language**: TypeScript (ESM) compiled to Node.js
- **Runtime**: Node 22+ (minimum); Bun supported for development/scripts
- **Build Tool**: TypeScript compiler (tsc)
- **Package Manager**: pnpm (10.23.0), also supports bun/npm
- **Testing**: Vitest with V8 coverage (70% threshold)
- **Linting/Formatting**: Oxlint, Oxfmt

### Frameworks & Libraries
- **CLI Framework**: Commander.js
- **Web UI**: Vite + Lit (Web Components)
- **AI Integration**: Anthropic Claude, OpenAI (OAuth + API key auth)
- **Platform-Specific**:
  - macOS/iOS: Swift with Xcode, SwiftUI (Observation framework preferred)
  - Android: Kotlin/Gradle
- **Agent Framework**: `@mariozechner/pi-agent-core`

## Project Structure

### Source Code (`/src/`)
- **agents/** - Pi agent orchestration, auth profiles, skills, and tools
- **cli/** - CLI wiring, commands, prompts, daemon/gateway management
- **commands/** - Top-level command handlers (agent, channels, models, etc.)
- **gateway/** - Gateway server core (WebSocket protocol, RPC methods)
- **channels/** - Channel integrations (WhatsApp, Telegram, Slack, Discord, Signal, iMessage, Teams)
- **browser/** - Browser automation (Playwright)
- **canvas-host/** - A2UI canvas rendering
- **config/** - Configuration & session management
- **media/** - Media pipeline
- **infra/** - Infrastructure utilities (binaries, ports, runtime guards)
- **logging/** - Structured logging (tslog)
- **plugins/** - Plugin system

### Platform Apps (`/apps/`)
- **macos/** - Swift macOS menu bar app
- **ios/** - Swift iOS app
- **android/** - Android/Kotlin app
- **shared/** - Shared mobile code

### Other Directories
- **/ui/** - Vite + Lit web UI
- **/docs/** - Mintlify documentation
- **/vendor/** - a2ui canvas rendering vendor
- **/tests/** - Colocated `*.test.ts` files throughout codebase

## Key Commands

### Development
```bash
pnpm install              # Install dependencies
pnpm clawdbot [cmd]       # Run CLI via bun
pnpm dev                  # Alias for pnpm clawdbot
pnpm build                # TypeScript compilation + canvas bundling
pnpm lint                 # Oxlint validation
pnpm format               # Oxfmt formatting
```

### Testing
```bash
pnpm test                 # Vitest unit tests
pnpm test:coverage        # Coverage report (70% gate)
pnpm test:live            # Tests with real API keys (CLAWDBOT_LIVE_TEST=1)
pnpm test:e2e             # E2E tests
pnpm test:docker:all      # Full Docker-based E2E
```

### Gateway Development
```bash
pnpm gateway:watch        # Auto-reload gateway on changes
pnpm gateway:dev          # Dev mode with logging
pnpm gateway:dev:reset    # Dev mode with state reset
```

### UI Development
```bash
pnpm ui:install           # Install UI dependencies
pnpm ui:dev               # Vite dev server
pnpm ui:build             # Production build
```

### Platform-Specific
```bash
pnpm ios:run              # Build & run iOS simulator
pnpm android:run          # Build & run Android emulator
pnpm mac:restart          # Rebuild macOS app
pnpm lint:swift           # SwiftLint validation
```

## Key Dependencies

### Core Libraries
- `@buape/carbon` (0.0.0-beta pinned version - never update)
- `@mariozechner/pi-*` - Pi agent framework
- `@whiskeysockets/baileys` - WhatsApp Web
- `grammy` - Telegram bot framework
- `@slack/bolt` - Slack SDK
- `commander` - CLI argument parsing
- `chalk` - Terminal colors
- `express` - HTTP server
- `ws` - WebSocket protocol
- `zod` - Schema validation
- `markdown-it` - Markdown parsing
- `sharp` - Image processing

### Infrastructure
- `node-llama-cpp` - Local LLM inference
- `playwright-core` - Browser automation
- `chromium-bidi` - Browser protocol
- `proper-lockfile` - File locking

## Code Conventions

### Style & Naming
- **Language**: TypeScript with strict mode enabled
- **File Size**: Keep files under ~700 LOC (guideline, not hard rule)
- **Naming**:
  - Product/documentation: "Clawdbot" (capitalized)
  - CLI/binary/configs: "clawdbot" (lowercase)
- **Comments**: Add brief comments for non-obvious logic
- **Types**: Avoid `any`; prefer explicit typing
- **Variable Prefixes**: Prefix role variables with role name (e.g., `kubero_version`)

### Testing Standards
- Colocated: `*.test.ts` files next to source
- E2E: `*.e2e.test.ts` files
- Coverage: 70% minimum for lines/branches/functions/statements
- Pure test additions/fixes don't need changelog entries

### Commit & PR Guidelines
- Use `scripts/committer "<msg>" <file...>` for scoped commits
- Run `pnpm lint && pnpm build && pnpm test` before pushing
- Changelog entries required for user-facing changes
- Group related changes; avoid bundling unrelated refactors

### SwiftUI State Management
- Prefer `Observation` framework (`@Observable`, `@Bindable`)
- Don't introduce new `ObservableObject` unless required for compatibility

## Architecture Patterns

### 1. Dependency Injection
- `createDefaultDeps()` provides injectable dependencies
- Promotes testability and loose coupling

### 2. CLI Profiles
- `--profile <name>` flag selects runtime configuration
- Enables dev/staging/production workflows

### 3. Channel Plugin System
- Channels are plugins with shared infrastructure
- Consistent auth + configuration across platforms

### 4. Gateway Server
- WebSocket-based RPC protocol
- Handler methods in `server-methods.ts`
- Health snapshots for status reporting

### 5. Agent System
- Built on Pi agent framework
- Auth profiles manage OAuth/API key rotation
- Subagent registry for agent chaining

### 6. Configuration
- YAML-based (`~/.clawdbot/config.yaml`)
- Session storage in `~/.clawdbot/sessions/`
- Environment variable overrides via dotenv

## Security & Configuration

### Credential Storage
- Bitwarden Secrets Manager for machine credentials
- Web provider credentials at `~/.clawdbot/credentials/`
- Environment variables for deployment
- Ansible Vault for encrypted config (IaC)

### Default Behaviors
- DM pairing policy for untrusted channels
- OAuth with Anthropic/OpenAI
- Configuration via YAML + environment overrides

## Documentation

Documentation lives in `/docs/` (Mintlify-based):
- Platform guides (macOS, iOS, Android, Linux, Windows)
- Concepts (models, failover, configuration)
- Gateway architecture & security
- Plugin development
- Testing procedures
- Installation & updating guides

### Documentation Standards
- Root-relative links (no `.md` extension)
- Generic placeholders (no real hostnames/paths)
- Full URLs in GitHub README

## Version Management

Versions are pinned in multiple locations:
- `package.json` - CLI version (semver YYYY.MM.DD)
- `apps/android/app/build.gradle.kts` - Android version
- `apps/ios/Sources/Info.plist` - iOS version
- `apps/macos/Sources/Clawdbot/Resources/Info.plist` - macOS version
- `docs/install/updating.md` - Documented npm version

## CI/CD

### GitHub Workflows
- `ci.yml` - Lint, build, test, coverage
- `install-smoke.yml` - Installation script testing
- `workflow-sanity.yml` - Workflow validation

### Test Suites
- Unit: `pnpm test`
- E2E: `pnpm test:e2e`
- Live: `pnpm test:live` (requires API keys)
- Docker: `pnpm test:docker:*` variants
- Coverage: `pnpm test:coverage`

## Multi-Agent Safety

When multiple agents work on this codebase:
- **Never** create/apply/drop `git stash` entries unless explicitly requested
- **Never** create/modify/remove `git worktree` checkouts
- **Never** switch branches unless explicitly requested
- Focus reports on your edits only; avoid guard-rail disclaimers
- When unrecognized files appear, keep going and focus on your changes
- Each agent should have its own session

## Special Notes

- **Carbon dependency**: Never update `@buape/carbon`
- **Patched dependencies**: Use exact versions (no `^`/`~`) for any dependency with `pnpm.patchedDependencies`
- **CLI progress**: Use `src/cli/progress.ts` (osc-progress + @clack/prompts spinner)
- **Exclamation marks**: Use heredoc pattern for `clawdbot message send` to avoid escaping issues
- **macOS gateway**: Runs only as menubar app; restart via app or `scripts/restart-mac.sh`
- **Device checks**: Verify connected real devices before using simulators/emulators
- **Tool schema guardrails**: Avoid `Type.Union` in tool schemas; use `stringEnum`/`optionalStringEnum`

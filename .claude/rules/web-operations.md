# Web Operations - Token Efficiency Rule

## Principle: Delegate Web Fetches to Agents

**Default behavior:** Always delegate web operations to agents to minimize token usage in the main conversation context.

## Token Impact

**Direct WebFetch/WebSearch:**
- ❌ Full page content (5K-20K+ tokens) → main conversation context
- ❌ Persists for entire conversation
- ❌ Multiple fetches = multiplicative bloat
- 💸 Expensive for every subsequent message

**Delegated to Agent:**
- ✅ Content isolated to agent's context
- ✅ Agent returns only extracted summary (100-500 tokens)
- ✅ Agent context discarded after completion
- 💰 Dramatically cheaper

## Implementation

### Use Task Tool with Subagents

```
Task tool with subagent_type="general-purpose" or "Explore"
→ Agent performs WebFetch/WebSearch
→ Agent processes and summarizes
→ Returns only relevant extracted information
```

### When to Use Direct WebFetch (Rare)

Only use direct WebFetch/WebSearch when **all** of these are true:
1. Page content is tiny (<500 tokens)
2. You will reference the exact raw content multiple times in main conversation
3. Processing/summarizing would lose critical details

## Examples

### ✅ Correct Pattern
```
User: "Check the latest Coolify API docs for database endpoints"
→ Use Task tool with general-purpose agent
→ Agent fetches docs, extracts database endpoint info
→ Returns: "Database endpoints: POST /databases, GET /databases/:uuid..."
→ Main context cost: ~200 tokens
```

### ❌ Incorrect Pattern
```
User: "Check the latest Coolify API docs"
→ Direct WebFetch to https://coolify.io/docs/api
→ Dumps 15K tokens of full API docs into main context
→ Main context cost: ~15K tokens + persists entire conversation
```

## Special Cases

- **Documentation lookups:** Delegate to agent (use Context7 MCP when available)
- **Library research:** Use web-search skill (already delegates to Perplexity agent)
- **Multi-page research:** Always delegate (agent can fetch multiple pages in its context)
- **Simple known URLs:** Still delegate unless truly tiny content

## Enforcement

When about to use WebFetch/WebSearch directly, ask yourself:
1. "Will this add >500 tokens to main context?"
2. "Am I doing research/lookup rather than repeated analysis?"

If yes to either → **delegate to agent instead**.

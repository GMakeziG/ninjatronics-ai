
## Agent routing

Nova must follow the routing policy in:

    shared/standards/agent-routing.md

The policy defines when to use Nova, Claude Code, Codex, and future specialist profiles. Before assigning concurrent implementation work, confirm that agents use separate Git worktrees or non-overlapping files.

## Persistent knowledge vault

Nova's canonical persistent knowledge base is:

```
vault/
```

The vault is an Obsidian vault shared between Nova and the user. It serves as Nova's long-term, human-readable memory for knowledge that should survive the current conversation or agent session.

The detailed rules governing the vault are defined in:

```
vault/AGENTS.md
```

Nova must follow `vault/AGENTS.md` whenever reading, creating, modifying, organizing, or archiving vault content.

### Persistence policy

Conversation context is temporary. The vault is persistent.

When Nova learns information that would be useful in a future session, Nova should preserve that knowledge in the vault as part of completing the work.

This includes, when relevant:

* System and infrastructure knowledge
* Architecture
* Project status and decisions
* Technical decisions and their rationale
* Troubleshooting discoveries
* Confirmed root causes
* Successful fixes
* Failed approaches that provide useful lessons
* Reusable commands
* Configuration patterns
* Runbooks and repeatable procedures
* Known issues and limitations
* Lessons learned
* Important user-established technical conventions
* Follow-up work that should not be forgotten

Nova should not require the user to explicitly say "remember this" when information clearly has long-term operational value.

### Before writing

Before creating a new vault note:

1. Search the vault for related information.
2. Prefer updating an existing relevant note.
3. Create a new note only when the subject is genuinely distinct.
4. Use `vault/1_Inbox/` when information is worth preserving but its permanent location is unclear.

Do not create duplicate notes simply because the exact filename Nova expected does not exist.

### Knowledge destinations

Use the vault directories according to their intended purpose:

```
vault/1_Inbox/        Unclassified information worth preserving
vault/2_Systems/      Systems, infrastructure, applications, and environments
vault/3_Projects/     Project knowledge, status, architecture, and decisions
vault/4_Runbooks/     Repeatable procedures and troubleshooting guides
vault/5_References/   Durable technical reference material
vault/6_Daily/        Chronological work records
vault/7_Templates/    Reusable Obsidian templates
vault/8_Attachments/  Supporting files and attachments
vault/9_Archives/     Inactive information that should be retained
```

### During substantial work

Nova does not need to record every command or conversation turn.

Instead, preserve knowledge when it becomes useful.

For substantial troubleshooting, implementation, research, or administration work, keep track of:

* What was being attempted
* Relevant environment and context
* Important evidence
* Commands or configuration that mattered
* Failed approaches that taught something
* Decisions made
* What ultimately worked
* Why it worked, when known
* How the result was verified
* Remaining work
* Gotchas worth remembering

At logical milestones, incorporate this knowledge into the appropriate permanent vault notes.

Do not dump raw conversation transcripts into the vault unless explicitly requested.

### Task completion

Before completing substantial work, Nova should ask internally:

> Did this task produce knowledge that would be useful in a future session?

If yes, preserve it in the vault before considering the task complete.

Prefer updating the appropriate System, Project, Runbook, or Reference note.

For substantial daily activity, Nova may additionally update:

```
vault/6_Daily/YYYY-MM-DD.md
```

Important knowledge must not exist only in a daily note. Promote durable information into the appropriate permanent note.

### Relationship to Graphify

Graphify and the Obsidian vault serve different purposes.

`graphify-out/` provides generated structural knowledge about the codebase.

`vault/` provides curated persistent knowledge for Nova and the user.

For codebase investigation:

1. Follow the Graphify policy below.
2. Verify important conclusions against source files.
3. Perform the work.
4. Preserve durable decisions, discoveries, procedures, or lessons in the vault when they have future value.

Do not copy generated Graphify output wholesale into the vault.

Instead, preserve the useful human-level conclusions derived from it.

### Repository documentation vs. vault knowledge

Do not move or duplicate documentation that belongs in the repository solely to place it in the vault.

Repository documentation such as:

```
README.md
CONTRIBUTING.md
docs/
architecture documentation
source-code documentation
```

should remain where the project expects it.

The vault may link to or summarize important repository documentation when doing so provides useful persistent context.

The vault is a knowledge base, not a replacement for repository documentation.

### Sensitive information

The vault is not a secrets manager.

Never intentionally persist:

* Passwords
* Private keys
* API tokens
* Authentication tokens
* MFA seeds
* Recovery codes
* Session cookies
* Encryption keys
* Other authentication secrets

Document where a secret is securely stored instead of recording the secret itself.

### Operating principle

Nova should treat:

```
vault/
```

as long-term external memory.

Work in the current context.

Use Graphify and source files to understand the codebase.

Use specialist agents according to `shared/standards/agent-routing.md`.

Preserve durable knowledge in the vault.

If knowledge would be frustrating, expensive, or time-consuming to rediscover later, it probably belongs in the vault.


## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- Dirty graphify-out/ files are expected after hooks or incremental updates; dirty graph files are not a reason to skip graphify. Only skip graphify if the task is about stale or incorrect graph output, or the user explicitly says not to use it.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After structural or meaningful code changes, or before completing a task that modified code, run `graphify update .` (AST-only, no API cost). Do not rebuild after documentation-only or trivial non-structural edits unless those files are part of the graph corpus.

Nova ownership and shared use are defined in `shared/standards/agent-routing.md` (Graphify is a shared capability, not a specialist profile). Graphify narrows search scope; it does not replace direct source inspection for high-risk decisions — verify important conclusions against the source files. Generated-artifact commit/ignore policy lives in that same standard.

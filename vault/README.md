# Nova Knowledge Vault

This is my personal **Obsidian knowledge vault** and the persistent knowledge base used by **Nova**, my Hermes AI agent.

The goal is simple: preserve useful information so I do not have to rediscover the same solutions, decisions, commands, and lessons later.

This vault is intended to work equally well for me in Obsidian and for Nova when searching, creating, or updating documentation.

---

## How This Vault Works

The Markdown files in this vault are the source of truth.

I can edit them directly through Obsidian, while Nova can read and maintain the same files.

Nova's operating rules are defined in:

```text
AGENTS.md
```

`README.md` is for me.

`AGENTS.md` is primarily for Nova.

---

## Vault Structure

```text
/
├── AGENTS.md
├── README.md
├── 1_Inbox/
├── 2_Systems/
├── 3_Projects/
├── 4_Runbooks/
├── 5_Reference/
├── 6_Daily/
├── 7_Templates/
├── 8_Attachments/
└── 9_Archive/
```

### Inbox

Temporary capture area.

Use this when I know something should be saved but I am not sure where it belongs yet.

Items here should eventually be organized elsewhere.

---

### Systems

Documentation about systems, infrastructure, applications, platforms, and environments.

Examples:

```text
Systems/Proxmox.md
Systems/FortiGate.md
Systems/Active Directory.md
Systems/FortiClient EMS.md
Systems/Grafana.md
```

Think:

> "What do I know about this system?"

---

### Projects

Active or historical project documentation.

Examples:

```text
Projects/Observability Platform.md
Projects/Proxmox IaC.md
Projects/FortiClient EMS Migration.md
```

Think:

> "What are we trying to accomplish?"

Projects should capture important decisions, progress, blockers, architecture, and lessons learned.

---

### Runbooks

Repeatable procedures.

Examples:

```text
Runbooks/Create Proxmox VM with OpenTofu.md
Runbooks/Restore VM from Veeam.md
Runbooks/Troubleshoot FortiGate Routing.md
```

Think:

> "How do I do this again?"

If I solve something difficult that I may encounter again, it probably deserves a runbook.

---

### Reference

Technical reference material that does not belong to a specific system or project.

Examples:

```text
Reference/Git Commands.md
Reference/Linux Networking.md
Reference/SSH.md
Reference/Ansible Vault.md
```

Think:

> "What do I need to remember about this technology?"

---

### Daily

Chronological work notes.

Filename format:

```text
YYYY-MM-DD.md
```

Example:

```text
2026-08-23.md
```

Daily notes are useful for remembering what happened on a particular day.

Important discoveries should eventually be incorporated into a permanent System, Project, Runbook, or Reference note.

---

### Templates

Reusable Obsidian templates.

Templates can be created for things such as:

* Systems
* Projects
* Runbooks
* Incidents
* Daily notes
* Technical decisions

---

### Attachments

Images, screenshots, diagrams, PDFs, logs, and other supporting files used by notes.

---

### Archive

Information worth keeping that is no longer active.

When possible:

**Archive instead of delete.**

---

# Working With Nova

Nova is allowed to help maintain this vault.

I can ask Nova things such as:

> Document what we just learned.

> Add this to the Proxmox notes.

> Create a runbook from today's troubleshooting.

> Update the FortiGate documentation with what we discovered.

> Search the vault and tell me what we previously learned about this issue.

> Put this in the Inbox for later.

> Turn today's work into permanent documentation.

> Find anything we've documented about this error.

Nova should search for existing information before creating duplicate notes.

The detailed rules Nova must follow are documented in:

```text
AGENTS.md
```

---

# Obsidian Links

Use Obsidian wikilinks to connect related knowledge:

```markdown
[[Proxmox Lab]]
[[FortiGate]]
[[Observability Platform]]
```

The goal is to gradually create relationships between systems, projects, procedures, and discoveries.

For example:

```text
[[FortiClient EMS Migration]]
          │
          ├── [[FortiClient EMS]]
          ├── [[Proxmox Lab]]
          ├── [[Veeam]]
          └── [[Restore VM from Veeam]]
```

Folders tell me **where information lives**.

Links tell me **how information relates**.

---

# Suggested Note Format

Permanent notes can use YAML frontmatter:

```yaml
---
title: Proxmox Lab
type: system
status: active
tags:
  - proxmox
  - virtualization
created: 2026-08-23
updated: 2026-08-23
---
```

Followed by normal Markdown:

```markdown
# Proxmox Lab

## Overview

...

## Configuration

...

## Known Issues

...

## Lessons Learned

...

## Related Notes

- [[OpenTofu]]
- [[Veeam]]
```

Not every note needs every section.

---

# Important Documentation Rule

When troubleshooting something, do not only document the final command that worked.

Useful documentation should explain:

1. What I was trying to accomplish.
2. What went wrong.
3. What symptoms I observed.
4. What I checked.
5. What failed.
6. What worked.
7. Why it worked, if known.
8. How I verified the fix.
9. What I should remember next time.

The failed attempts are often just as valuable as the final solution.

---

# Facts vs. Assumptions

Technical notes should make uncertainty obvious.

For example:

```markdown
## Confirmed

Traffic reaches the FortiGate.

## Suspected

The firewall policy may be blocking TCP 3389.

## To Verify

- Check the forward policy.
- Run debug flow.
```

A theory should not become documented as a root cause until it is supported by evidence.

---

# Secrets

This vault is **not a password manager or secrets vault**.

Do not intentionally store:

* Passwords
* API tokens
* Private SSH keys
* MFA seeds
* Recovery codes
* Session cookies
* Encryption keys
* Other authentication secrets

Instead, document where the secret is managed.

Example:

```text
Grafana credentials are stored in Ansible Vault.
```

---

# Git

If this vault is stored in Git, commit meaningful documentation changes regularly.

Example:

```bash
git status
git add .
git commit -m "docs: add Proxmox VM deployment runbook"
git push
```

Before committing, make sure no credentials, private keys, tokens, or sensitive attachments were accidentally added.

---

# Quick Rule of Thumb

When deciding where something belongs:

| Question                                      | Location     |
| --------------------------------------------- | ------------ |
| I don't know where this belongs yet           | `Inbox/`     |
| What do I know about this system?             | `Systems/`   |
| What am I building or changing?               | `Projects/`  |
| How do I do this again?                       | `Runbooks/`  |
| What do I need to know about this technology? | `Reference/` |
| What happened today?                          | `Daily/`     |
| Is this no longer active but worth keeping?   | `Archive/`   |

---

# The Goal

This vault should become my long-term technical memory.

When I encounter something six months from now, I should be able to search this vault and answer:

> Have I seen this before?

> How did I fix it?

> Why did we configure it this way?

> What did we learn last time?

> Is there already a runbook for this?

Nova should help make those answers easier to find over time.

**Document once. Find it later. Improve it when we learn more.**


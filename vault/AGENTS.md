# AGENTS.md — Nova Obsidian Vault

## Purpose

This Obsidian vault is a persistent knowledge base managed collaboratively by the user and **Nova**, a Hermes AI agent.

Nova may read, create, organize, link, and update Markdown notes in this vault to preserve useful knowledge across conversations and tasks.

The vault is intended to remain:

* Useful to a human reader.
* Easy for an AI agent to search and understand.
* Organized without excessive hierarchy.
* Portable as standard Markdown.
* Safe from accidental deletion or destructive reorganization.
* Free of unnecessary duplicate information.

The Markdown files in this vault are the primary source of truth for information intentionally stored here.

---

# 1. Core Rules

Nova MUST follow these rules whenever interacting with this vault.

1. Preserve existing information unless explicitly instructed to remove it.
2. Prefer updating an existing relevant note over creating a duplicate.
3. Never delete notes, directories, attachments, or substantial content unless explicitly instructed.
4. Never modify the `.obsidian/` directory unless explicitly instructed.
5. Use standard Markdown wherever possible.
6. Use Obsidian `[[wikilinks]]` to connect related knowledge.
7. Keep notes understandable without requiring access to the original conversation that created them.
8. Clearly distinguish verified facts from assumptions, hypotheses, recommendations, and unresolved questions.
9. Do not fabricate information to fill gaps.
10. Preserve important technical details such as commands, paths, hostnames, configuration values, error messages, and lessons learned when they are relevant.
11. Do not store passwords, private keys, API tokens, recovery codes, session cookies, or other authentication secrets.
12. Before creating a new note, check whether the information belongs in an existing note.
13. Favor useful content over elaborate formatting.
14. Keep the vault usable by both Nova and the user.

---

# 2. Vault Structure

Use the following primary directories:

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

Do not create new top-level directories unless there is a clear long-term organizational reason.

Avoid deeply nested directory structures.

Prefer:

```text
Systems/FortiGate.md
Systems/Proxmox.md
Projects/Observability.md
```

over structures such as:

```text
Technology/Infrastructure/Networking/Firewalls/Fortinet/FortiGate/
```

Use links, tags, and metadata to represent relationships instead of excessive directory nesting.

---

# 3. Directory Responsibilities

## Inbox/

Use `Inbox/` when information:

* Has not yet been classified.
* Needs additional investigation.
* Is a temporary capture.
* Does not clearly belong elsewhere.

Inbox notes should eventually be moved or incorporated into permanent notes.

Do not allow `Inbox/` to become permanent storage.

---

## Systems/

Use `Systems/` for knowledge about persistent systems, infrastructure, applications, devices, platforms, and environments.

Examples:

```text
Systems/Proxmox.md
Systems/FortiGate.md
Systems/FortiClient EMS.md
Systems/Grafana.md
Systems/Active Directory.md
```

A system note should describe what the system is, how it is used, important configuration information, dependencies, operational considerations, and links to relevant runbooks or projects.

---

## Projects/

Use `Projects/` for work with a defined goal or outcome.

Examples:

```text
Projects/Observability Platform.md
Projects/FortiClient EMS Migration.md
Projects/Proxmox IaC.md
```

Project notes may contain:

* Objective
* Current status
* Architecture
* Decisions
* Tasks
* Blockers
* Lessons learned
* Related systems
* Related runbooks

When a project is completed, retain the useful project history or move the note to `Archive/` if it no longer needs to remain active.

---

## Runbooks/

Use `Runbooks/` for repeatable operational procedures.

Examples:

```text
Runbooks/Create Proxmox VM with OpenTofu.md
Runbooks/Restore VM from Veeam.md
Runbooks/Troubleshoot FortiGate Routing.md
```

Runbooks should prioritize reproducibility.

Include when appropriate:

* Purpose
* Preconditions
* Required access
* Commands
* Procedure
* Verification
* Rollback
* Troubleshooting
* Known issues
* Gotchas
* References

Commands MUST be placed in fenced code blocks.

Example:

```bash
sudo systemctl status ssh
```

Do not alter commands merely to make them look cleaner if doing so could change their behavior.

---

## Reference/

Use `Reference/` for durable reference material that is neither a system nor a project.

Examples include:

* Command references
* Technology explanations
* Standards notes
* Architecture concepts
* Git references
* Linux references
* Configuration syntax

---

## Daily/

Use `Daily/` for chronological notes.

Recommended filename:

```text
YYYY-MM-DD.md
```

Example:

```text
2026-08-23.md
```

Daily notes should capture significant work, discoveries, decisions, and unresolved items when chronological context is useful.

Important information should eventually be incorporated into the appropriate permanent system, project, reference, or runbook note.

Daily notes are not a substitute for permanent documentation.

### Daily note preservation

Daily notes are cumulative records for the entire day.

When `6_Daily/YYYY-MM-DD.md` already exists:

1. Read the existing file before modifying it.
2. Preserve all existing entries.
3. Add new work as a new `##` section.
4. Never replace the day's title or previous sections merely because the current task is unrelated.
5. Do not rewrite a daily note as though the current task were the only activity that occurred that day.
6. If restructuring is useful, preserve every existing item during the restructuring.

The daily note should have one top-level date heading:

    # YYYY-MM-DD

Each distinct activity should normally be added beneath it as a second-level heading:

    ## Activity or task name

Subsections for that activity should use third-level headings:

    ### What was attempted
    ### What happened
    ### What worked
    ### What didn't work
    ### How it was verified
    ### Decisions made
    ### Remaining work

Example:

    # 2026-08-23

    ## Nginx troubleshooting

    ...

    ## Zaifu Phase 0 Specialist Work

    ### What was attempted

    ...

Before saving an existing daily note, verify that previously recorded activities remain present.
---

## Templates/

Use `Templates/` for reusable Obsidian note templates.

Do not modify established templates without a reason.

---

## Attachments/

Store images, PDFs, diagrams, exported logs, and other supporting files here when appropriate.

Markdown notes should link to attachments rather than duplicating their contents unnecessarily.

---

## Archive/

Use `Archive/` for information that should be retained but is no longer active.

Archiving is preferred over deletion.

---

# 4. Note Naming

Use descriptive human-readable filenames.

Prefer:

```text
FortiClient EMS Migration.md
Proxmox Lab.md
Git Branch Recovery.md
```

Avoid:

```text
notes1.md
stuff.md
temp2.md
random.md
new-note.md
```

Do not include unnecessary dates in filenames unless the date is meaningful.

Use dates for chronological records such as:

```text
2026-08-23.md
2026-08-23 FortiGate Incident.md
```

---

# 5. Frontmatter

Use YAML frontmatter for permanent notes when metadata provides useful context.

Recommended format:

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

Common `type` values:

```text
system
project
runbook
reference
incident
decision
daily
```

Common `status` values:

```text
active
planned
blocked
completed
deprecated
archived
```

Do not add metadata simply for the sake of having metadata.

When substantially updating a note, update its `updated` date if that field exists.

Do not change the original `created` date.

---

# 6. Linking

Use Obsidian wikilinks:

```markdown
[[Proxmox Lab]]
[[FortiClient EMS]]
[[Observability Platform]]
```

Use display text when helpful:

```markdown
[[Proxmox Lab|Proxmox environment]]
```

When creating or substantially updating a note, identify obvious relationships with existing notes.

Prefer meaningful contextual links over large unrelated lists of links.

Do not create empty notes merely because a possible link exists.

---

# 7. Tags

Use tags sparingly.

Good examples:

```text
#linux
#networking
#security
#proxmox
#fortigate
#automation
```

Avoid creating several variations representing the same concept.

For example, do not simultaneously introduce:

```text
#FortiGate
#fortigate
#fortinet-firewall
#fortigate-firewall
```

Reuse existing tags whenever practical.

Links describe relationships between knowledge.

Tags describe broad categories.

---

# 8. Updating Existing Notes

Before creating a new note:

1. Search for notes covering the same system, project, procedure, or concept.
2. Determine whether the new information belongs there.
3. Update the existing note when appropriate.
4. Create a new note only when the information represents a distinct subject.

When updating a note:

* Preserve useful existing information.
* Integrate new information into the appropriate section.
* Avoid simply appending unrelated conversation transcripts.
* Update outdated information when the newer information is verified.
* Preserve historical context when understanding the change is useful.

If new information contradicts existing documentation and the correct answer cannot be established, document the discrepancy instead of silently replacing one claim with another.

---

# 9. Duplicate Prevention

Nova MUST actively avoid duplicate notes.

Before creating:

```text
Systems/FortiGate Firewall.md
```

check whether notes such as these already exist:

```text
FortiGate.md
Fortinet.md
FortiGate Lab.md
Network Firewall.md
```

If an existing note covers the same concept, improve it instead.

When duplicate notes are discovered, Nova may recommend consolidation.

Nova MUST NOT delete or merge substantial existing notes without permission when doing so could result in information loss.

---

# 10. Facts, Assumptions, and Conclusions

Do not present uncertain information as fact.

Use clear labels when necessary:

```markdown
## Confirmed

The service listens on TCP 443.

## Suspected

The failure may be related to DNS resolution.

## To Verify

- Confirm the DNS server configured on the host.
- Check whether TCP 443 is reachable.
```

When troubleshooting, preserve the distinction between:

* Symptoms
* Evidence
* Hypotheses
* Tests performed
* Results
* Root cause
* Resolution

Do not rewrite a hypothesis as a root cause merely because troubleshooting later succeeded.

---

# 11. Technical Documentation

Technical notes should preserve information required to reproduce or understand the work.

Capture when relevant:

* Commands
* Configuration snippets
* File paths
* Software versions
* Hostnames
* Network relationships
* Error messages
* Troubleshooting steps
* Successful fixes
* Failed approaches
* Verification steps
* Dependencies
* Lessons learned
* Gotchas

A failed command can be valuable documentation when it explains what not to do.

Do not remove failed approaches from incident or troubleshooting documentation merely because a later solution worked.

---

# 12. Runbook Quality

A runbook should allow someone unfamiliar with the original incident to perform the procedure safely.

Prefer:

````markdown
# Restarting the Service

## Purpose

Restart the application service after configuration changes.

## Preconditions

- SSH access to the server
- sudo privileges

## Procedure

1. Verify the current state.

   ```bash
   systemctl status example
````

2. Restart the service.

   ```bash
   sudo systemctl restart example
   ```

3. Verify that it returned successfully.

   ```bash
   systemctl status example
   ```

## Verification

Confirm the service reports `active (running)`.

## Rollback

...

## Gotchas

...

````

Avoid runbooks that are only unexplained collections of commands.

---

# 13. Incident Documentation

Incident notes should capture chronology and evidence.

Recommended structure:

```markdown
# Incident Title

## Summary

## Impact

## Environment

## Symptoms

## Timeline

## Investigation

## Root Cause

## Resolution

## Verification

## Lessons Learned

## Follow-Up Actions

## Related Notes
````

If the root cause has not been established, explicitly state:

```text
Root cause not yet confirmed.
```

Never invent a root cause.

---

# 14. Decision Records

Important technical decisions should be preserved.

Use a section or dedicated note containing:

```markdown
## Decision

What was decided.

## Reason

Why this approach was selected.

## Alternatives Considered

Other approaches considered.

## Consequences

Important effects or tradeoffs.
```

This prevents future troubleshooting from undoing intentional configuration because the reason for it was forgotten.

---

# 15. Sources

When information comes from external documentation, preserve the source when practical.

Example:

```markdown
## References

- Fortinet Administration Guide — relevant feature/topic
- Vendor support case — case reference
```

For web sources, retain the relevant URL when available.

For internal information, identify the source without exposing secrets.

Do not fabricate citations or references.

---

# 16. Sensitive Information

The vault may contain operational information but MUST NOT be treated as a secrets manager.

Never intentionally store:

* Passwords
* Private SSH keys
* API secrets
* Access tokens
* Session tokens
* Recovery codes
* MFA seeds
* Authentication cookies
* Private certificates
* Encryption keys

It is acceptable to document where a secret is stored.

Prefer:

```text
Grafana administrator password is stored in the Ansible Vault.
```

Never:

```text
Grafana password: SuperSecretPassword123
```

If sensitive credentials appear in source material, do not copy them into permanent notes unless explicitly instructed and appropriate safeguards exist.

---

# 17. Destructive Actions

Nova MUST request confirmation before:

* Deleting notes.
* Deleting attachments.
* Removing substantial sections of documentation.
* Performing large-scale renames.
* Performing large-scale directory moves.
* Consolidating notes when information might be lost.
* Reorganizing the entire vault.
* Modifying `.obsidian/`.

When cleanup is appropriate, prefer moving obsolete material to:

```text
Archive/
```

rather than deleting it.

---

# 18. Obsidian Configuration

The `.obsidian/` directory belongs to Obsidian.

Do not modify it unless explicitly requested.

This includes:

* Plugin configuration
* Workspace state
* Appearance settings
* Hotkeys
* Obsidian application settings

Nova's normal work should occur in Markdown files and supporting attachments.

---

# 19. Conversation-to-Knowledge Conversion

Do not dump entire conversations into permanent notes by default.

Extract the useful knowledge.

For troubleshooting conversations, capture:

1. What was being attempted.
2. Environment involved.
3. Original symptoms.
4. Relevant evidence.
5. Commands used.
6. What failed.
7. What worked.
8. Root cause, if confirmed.
9. Verification.
10. Lessons learned.
11. Future procedure.

Remove conversational filler that provides no future value.

Preserve exact technical details when they matter.

---

# 20. Memory and Long-Term Knowledge

Treat the vault as long-term external memory.

Information worth preserving generally includes:

* Architecture decisions
* Environment characteristics
* System relationships
* Established conventions
* Repeatable procedures
* Troubleshooting discoveries
* Known limitations
* Important configuration decisions
* Project status
* Lessons learned
* User-established technical preferences

Temporary conversational details generally do not require permanent storage.

When uncertain whether something deserves permanent documentation, place it in `Inbox/` rather than modifying established documentation unnecessarily.

---

# 21. Human Readability

Every note should remain useful if Nova is unavailable.

Avoid agent-specific shorthand that only Nova understands.

Prefer:

```markdown
The VM uses 1.1.1.1 for DNS because the previous resolver failed to resolve external domains during deployment.
```

over:

```markdown
DNS fixed per previous context.
```

Never rely on undocumented conversational memory to explain a note.

---

# 22. Markdown Standards

Use:

```markdown
# Title

## Major Section

### Subsection
```

Use fenced code blocks with appropriate languages:

````markdown
```bash
ip addr
```

```powershell
Get-ADUser username
```

```nix
programs.starship.enable = true;
```

```yaml
services:
  example:
    image: example
```
````

Use tables only when tabular information genuinely improves readability.

Use checklists for actionable work:

```markdown
- [ ] Verify backup
- [ ] Apply configuration
- [ ] Test connectivity
- [ ] Document results
```

---

# 23. Change Discipline

Nova should make the smallest reasonable change necessary.

For a requested update to one system:

* Update that system's documentation.
* Update directly related links if necessary.
* Do not reorganize unrelated parts of the vault.

Large cleanup operations should be proposed separately.

---

# 24. When Information Changes

When a previously documented value changes, determine whether the old value has historical importance.

For ordinary current-state documentation, update the value.

For migrations, incidents, architecture decisions, or other historically significant changes, preserve both states.

Example:

```markdown
## Network History

- Previous address: `192.168.1.9`
- Current address: `192.168.1.6`
- Changed during migration testing.
```

This is preferable to silently removing information that may explain older logs or documentation.

---

# 25. Related Notes

When appropriate, finish permanent notes with:

```markdown
## Related Notes

- [[Related System]]
- [[Relevant Project]]
- [[Relevant Runbook]]
```

Only include meaningful relationships.

---

# 26. Nova's Operating Principle

When deciding how to manage the vault, Nova should prioritize, in this order:

1. **Do not lose information.**
2. **Do not expose secrets.**
3. **Do not invent facts.**
4. **Keep existing knowledge accurate.**
5. **Improve existing notes before creating duplicates.**
6. **Make important knowledge easy to find.**
7. **Connect related knowledge.**
8. **Preserve useful historical context.**
9. **Keep documentation reproducible.**
10. **Keep the vault simple enough for a human to maintain.**

The goal is not to create the largest possible knowledge base.

The goal is to create a **reliable, connected, searchable, and maintainable technical memory**.


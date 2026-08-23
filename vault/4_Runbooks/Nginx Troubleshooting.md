---
title: Nginx Troubleshooting
type: runbook
status: active
tags:
  - nginx
  - linux
  - web
  - troubleshooting
created: 2026-08-23
updated: 2026-08-23
---

# Nginx Troubleshooting

## Purpose

General runbook for diagnosing and resolving Nginx configuration failures on **test-web-01** (and other Nginx hosts). Use this as the starting point for any Nginx start/restart failure. For specific known issues, see the cross-references at the bottom.

## Affected System

- **test-web-01** — Ubuntu server running Nginx

## Preconditions

- SSH access to the affected server.
- Sudo/root privileges to edit Nginx config and restart the service.

## General Process

Follow these steps in order for any Nginx failure.

### 1. Validate before changing anything

```bash
sudo nginx -t
```

`nginx -t` parses the full configuration (including all included files) and reports the first error it encounters with the file path and line number. This is the single most important diagnostic command — never skip it.

### 2. Read the error message

The error message from `nginx -t` identifies:

- The config file path
- The line number
- The type of error (unknown directive, duplicate, syntax)

Read it carefully before making any change. Do not guess — the message tells you exactly where to look.

### 3. Identify the failure class

Common failure classes:

| Error pattern | Cause | Fix |
|---|---|---|
| `unknown directive` | Typo, misspelled directive, or missing semicolon on the previous line | Correct the directive name or add the missing semicolon |
| `duplicate` | Same directive (e.g. `listen`, `server_name`) defined twice in the same context | Remove the duplicate |
| `invalid parameter` | Wrong value for a directive (e.g. invalid port, unknown variable) | Correct the parameter value |
| `host not found` | DNS resolution failure for an `upstream` or `server_name` | Check DNS or upstream availability |
| `permission denied` | File permissions or SELinux/AppArmor | Check file ownership and permissions |
| `bind() failed` | Port already in use by another process | Identify the process with `sudo ss -tlnp | grep :<port>` and resolve the conflict |

### 4. Fix the identified issue

Edit the config file at the line reported by `nginx -t`. Common tips:

- For `unknown directive`: check the spelling against the [Nginx directive index](https://nginx.org/en/docs/dirindex.html). Also check the line above — a missing semicolon on the previous line causes the parser to treat the next directive name as an argument, producing an "unknown directive" error on a line that is itself correctly written.
- For `duplicate`: remove the redundant entry, keeping only one per context.
- After editing, verify the file has no obvious syntax issues (missing semicolons, unclosed braces).

### 5. Re-validate

```bash
sudo nginx -t
```

Always run `nginx -t` again after making changes. If it reports a new error, the first fix revealed a second problem — repeat from step 2. Do not restart Nginx until `nginx -t` reports `test is successful`.

### 6. Restart Nginx

```bash
sudo systemctl restart nginx
```

### 7. Verify the service and the site

```bash
sudo systemctl status nginx
curl -sI https://localhost | head -n 1
```

Or open the site URL in a browser and confirm a 200 response.

## Common Pitfalls

- **Skipping `nginx -t` and going straight to restart.** The restart will fail with a less informative message. Always validate first.
- **Missing semicolon on the line above.** This produces an "unknown directive" error on the next line, which is misleading — the real problem is one line up.
- **Editing the wrong file.** Nginx config is split across `/etc/nginx/nginx.conf` and included files under `/etc/nginx/sites-enabled/`, `/etc/nginx/conf.d/`, etc. The error message names the exact file — edit that one.
- **Forgetting included files.** A directive in an included file can conflict with one in the parent. Check the full include chain if the error doesn't make sense.
- **Not re-validating after a fix.** A fix can reveal a second error that was masked by the first. Always re-run `nginx -t` before restarting.

## Known Issue Types

For detailed procedures on specific recurring failures:

- [[Nginx Duplicate Listen Directive]] — duplicate `listen` directive for the same port in one server block.

## If It Happens Again

1. Run `sudo nginx -t` and read the error — it names the file and line.
2. Identify the failure class from the table above.
3. Fix the issue at the reported line.
4. Re-run `sudo nginx -t` until it passes.
5. `sudo systemctl restart nginx`.
6. Verify with `systemctl status nginx` and `curl -sI https://localhost`.

## Related

- [[test-web-01]]

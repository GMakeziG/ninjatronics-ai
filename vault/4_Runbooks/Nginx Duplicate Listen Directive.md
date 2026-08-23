---
title: Nginx Duplicate Listen Directive
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

# Nginx Duplicate Listen Directive

## Purpose

Resolve the case where `nginx -t` fails because port 443 (or another port) is defined more than once for the same server block, preventing Nginx from starting.

## Affected System

- **test-web-01** — Ubuntu server running Nginx

## Root Cause

A `listen 443 ssl;` directive appeared twice in the same `server` block. Nginx treats duplicate listen directives for the same port within one server as a configuration error and refuses to start.

## Symptoms

- `nginx -t` returns an error similar to `duplicate listen ... 443` for the same server.
- `systemctl start nginx` or `systemctl restart nginx` fails.
- The site is not responding over HTTPS.

## Preconditions

- SSH access to the affected server.
- Sudo/root privileges to edit Nginx config and restart the service.

## Procedure

1. Validate the configuration to see the exact error:

   ```bash
   sudo nginx -t
   ```

2. Identify the offending `server` block. The error message names the file and line number.

3. Open the file and locate the duplicate `listen 443 ssl;` directive within the same `server` block.

4. Remove the duplicate so only one `listen 443 ssl;` remains per server block.

5. Re-validate:

   ```bash
   sudo nginx -t
   ```

6. Restart Nginx:

   ```bash
   sudo systemctl restart nginx
   ```

## Verification

1. Confirm Nginx is running:

   ```bash
   sudo systemctl status nginx
   ```

2. Confirm the site responds over HTTPS:

   ```bash
   curl -sI https://localhost | head -n 1
   ```

   Or open the site URL in a browser and confirm a 200 response.

## What We Learned

- Duplicate `listen` directives for the same port within one `server` block are a hard error in Nginx, not a warning. Nginx will not start until the conflict is resolved.
- `nginx -t` is the fastest way to identify this class of problem — it names the file and line. Always run it after editing Nginx config and before restarting the service.
- This issue is most likely to appear after manual edits that copy/paste a server block or merge configurations. Review pasted blocks for duplicated listen lines.

## If It Happens Again

1. Run `sudo nginx -t` and read the error message — it identifies the file and line number of the duplicate.
2. Check all `server` blocks in the referenced file (and any included files) for `listen 443 ssl;` appearing more than once per block.
3. Common causes to look for:
   - A server block was duplicated or templated and both copies kept the same listen line.
   - A config include file and the parent file both define the listen directive for the same server.
   - A port was changed in one place but not all, leaving a stale listen line.
4. Remove the duplicate, re-run `nginx -t`, restart, and verify HTTPS.

## Related

- [[test-web-01]]
- [[Nginx Troubleshooting]] — general Nginx troubleshooting runbook (start here for any Nginx failure).

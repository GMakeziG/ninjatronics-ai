#!/usr/bin/env python3
"""Reproducible, no-install Markdown relative-link checker for the Zaifu repo.

Scans every tracked *.md file, extracts inline Markdown links, and reports any
relative link target that does not resolve on disk. External (http/https/mailto)
links and pure in-page anchors are reported as skipped, not broken.
"""
import os, re, subprocess, sys, urllib.parse

ROOT = os.path.abspath(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ROOT = subprocess.run(["git", "rev-parse", "--show-toplevel"],
                      capture_output=True, text=True, check=True).stdout.strip()

files = subprocess.run(["git", "ls-files", "*.md"], cwd=ROOT,
                       capture_output=True, text=True, check=True).stdout.split()

LINK = re.compile(r'(?<!\!)\[[^\]]*\]\(\s*([^)\s]+)(?:\s+"[^"]*")?\s*\)')
FENCE = re.compile(r'^\s*```')

broken, checked, skipped = [], 0, 0
for rel in sorted(files):
    path = os.path.join(ROOT, rel)
    in_fence = False
    with open(path, encoding="utf-8") as fh:
        for lineno, line in enumerate(fh, 1):
            if FENCE.match(line):
                in_fence = not in_fence
                continue
            if in_fence:
                continue
            for target in LINK.findall(line):
                if re.match(r'^(https?:|mailto:|#)', target):
                    skipped += 1
                    continue
                frag = urllib.parse.unquote(target.split("#", 1)[0])
                if not frag:
                    skipped += 1
                    continue
                checked += 1
                resolved = os.path.normpath(os.path.join(os.path.dirname(path), frag))
                if not os.path.exists(resolved):
                    broken.append(f"{rel}:{lineno}: {target} -> {os.path.relpath(resolved, ROOT)}")

print(f"markdown files scanned : {len(files)}")
print(f"relative links checked : {checked}")
print(f"external/anchor skipped: {skipped}")
print(f"broken relative links  : {len(broken)}")
for b in broken:
    print("  BROKEN " + b)
sys.exit(1 if broken else 0)

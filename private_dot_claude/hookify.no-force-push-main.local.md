---
name: no-force-push-main
enabled: true
event: bash
action: block
pattern: git\s+push\s+.*--force.*\s+(main|master)|git\s+push\s+.*-f\s+.*(main|master)
---

**Force push to main/master is blocked.**

This is a destructive operation that rewrites shared history. Alternatives:
- Push to a feature branch and open a PR
- Use `--force-with-lease` on a feature branch if you must force push
- If you genuinely need to force push main, get explicit user approval first

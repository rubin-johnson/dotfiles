---
name: automate
description: Retrospective automation analysis — scan claude-mem session history for repeated manual sequences, surface candidates, and script the confirmed ones to ~/.claude/bin/.
---

# /automate

## What This Does

Scans claude-mem for bash commands and multi-step sequences you've done manually across sessions. Surfaces the top candidates ranked by frequency. For each confirmed candidate, creates a script in `~/.claude/bin/` and adds a row to the `## Automations` table in `~/.claude/CLAUDE.md`.

## Process

### Step 1: Query claude-mem for repeated patterns

Use the claude-mem MCP search tool to find observations containing bash commands or multi-step sequences:

Search queries to run (run all three, then deduplicate):
- `"bash"` or `"shell"` — finds logged command sequences
- `"chezmoi"` — finds repeated dotfiles operations
- `"manually"` or `"each time"` — finds pain points explicitly noted

Group results by similarity. Look for:
- The same 2+ step sequence appearing in 3+ separate sessions
- Commands that always appear together (run A → then B → then C)
- Anything you've done more than twice that has no script in `~/.claude/bin/`

Cross-reference against `## Automations` in `~/.claude/CLAUDE.md` — exclude patterns that are already scripted.

### Step 2: Present candidates

Format:

```
Automation candidates from session history:

1. [sequence description]  [seen Nx across Y sessions]
   Steps: step1 → step2 → step3

2. [sequence description]  [seen Nx across Y sessions]
   Steps: ...

Script any of these? Enter numbers (e.g. "1 3"), "all", or "none":
```

If fewer than 2 candidates found: "Not enough history yet to identify patterns. I'll flag candidates as I notice them during sessions."

### Step 3: For each confirmed candidate

For each number the user confirms:

1. **Propose a script name** — short, imperative, kebab-case (e.g. `chezmoi-sync`, `sso-login`, `compose-up`). Ask for approval if unsure.

2. **Write the script** to `private_dot_claude/bin/executable_<name>` in the dotfiles repo (if on a chezmoi machine) or directly to `~/.claude/bin/<name>`:

   Script template:
   ```bash
   #!/bin/bash
   # <one-line description>
   # Usage: <name> [args]

   set -euo pipefail

   # [implementation]
   ```

3. **Make it executable:**
   ```bash
   chmod +x ~/.claude/bin/<name>
   ```

4. **Add a row to `## Automations`** in `~/.claude/CLAUDE.md`:
   ```
   | `<name>` | <when to use> | `<name> [args]` |
   ```

5. **If chezmoi-managed:** Run `chezmoi re-add` on both the script and CLAUDE.md.

6. **Show proposed commit** and wait for approval:
   ```
   Files changed:
   - private_dot_claude/bin/executable_<name>  (new script)
   - private_dot_claude/CLAUDE.md  (Automations table updated)

   Commit message: "feat: automate <sequence description>"

   Proceed? [yes/no]
   ```

### Step 4: Wrap up

After processing all candidates: "Done. Run `/automate` again after a few more sessions to catch new patterns."

## In-Session Detection (Reference)

When working on any task, if I'm about to do a multi-step sequence manually:
1. Check claude-mem for prior occurrences of the same sequence
2. If found 2+ times in prior sessions: pause and ask "I've done X across sessions — should I script this as `<proposed-name>`?"
3. If yes: follow Step 3 above for that single candidate
4. If no: note in claude-mem "user declined to automate: [sequence]" to avoid re-flagging

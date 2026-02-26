---
name: automate:setup
description: Initialize the Automations system — adds the ## Automations section to ~/.claude/CLAUDE.md and ensures ~/.claude/bin/ exists. Run once on a new machine or after a fresh Claude Code install.
---

# automate:setup

## What This Does

Sets up the Automations system so Claude knows to use scripts in `~/.claude/bin/` instead of doing repetitive work manually.

## Steps

1. Check if `~/.claude/bin/` exists. If not, create it:
   ```bash
   mkdir -p ~/.claude/bin
   ```

2. Check if `~/.claude/CLAUDE.md` already contains `## Automations`. Use Grep to search for the heading.

3. If the section is **missing**, append it to the end of `~/.claude/CLAUDE.md`:
   ```markdown

   ---

   ## Automations

   Scripts in `~/.claude/bin/` — use these instead of doing the work manually.
   When I notice a repeated multi-step sequence, I'll ask if you want it scripted.
   Use `/automate` to review candidates from session history.

   | Script | When to use | Usage |
   |--------|-------------|-------|
   ```

4. If the section is **already present**, report "Automations section already exists — nothing to do."

5. If changes were made and this is a chezmoi-managed machine (check: `~/.local/share/chezmoi` exists):
   ```bash
   chezmoi re-add ~/.claude/CLAUDE.md
   ```
   Then show the proposed commit but do NOT commit — wait for user approval per standard workflow.

6. Confirm: "Setup complete. Automations section is in `~/.claude/CLAUDE.md`. Add scripts to `~/.claude/bin/` and update the table as you build automations."

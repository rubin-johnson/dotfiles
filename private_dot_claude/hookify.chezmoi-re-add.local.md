---
name: chezmoi-re-add
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: /home/rujohnson/\.claude/
---

**Remember to sync with chezmoi.**

You edited a file under `~/.claude/` which is managed by chezmoi. After your changes:
1. Run `chezmoi re-add <file>` to sync back to the dotfiles repo
2. Commit the updated source file in `~/dotfiles/`

Without this step, `chezmoi apply` will overwrite your changes.

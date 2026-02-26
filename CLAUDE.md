# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal WSL2/Debian dotfiles managed with [chezmoi](https://www.chezmoi.io/). Configures shell, dev tools, and Claude Code.

## Chezmoi Naming Conventions

| Prefix/Suffix | Meaning |
|---------------|---------|
| `dot_` | Leading `.` (dot_bashrc → ~/.bashrc) |
| `private_` | Mode 0600 |
| `.tmpl` | Go template (uses `{{ .chezmoi.* }}` variables) |
| `run_once_before_` | Install script, runs once before files applied |
| `run_once_after_` | Install script, runs once after files applied |

## Commands

```bash
chezmoi diff          # Preview changes
chezmoi apply         # Apply changes
chezmoi verify        # Check all files match (exit 0 = pass)
chezmoi doctor        # Check for config issues
chezmoi data          # Show template variables
```

## Structure

- `dot_*` — Shell config, aliases, vim
- `private_dot_claude/` — Claude Code config (global CLAUDE.md, hooks, scripts, token tracking)
- `.chezmoiscripts/` — Tool installers (apt, pyenv, go, terraform, claude)
- `.chezmoi.toml.tmpl` — Prompted config (name, email)
- `.chezmoiignore` — Files to exclude from chezmoi management

## Install Scripts

Scripts in `.chezmoiscripts/` run in alphabetical order:
1. `00-install-apt-packages` - Base packages
2. `01-install-oh-my-zsh` - Shell + plugins
3. `02-install-pyenv` - Python version manager
4. `03-install-aws-cli` - AWS CLI v2 (arch-aware)
5. `04-install-go` - Go + golangci-lint (arch-aware)
6. `05-install-claude` - Claude Code CLI
7. `05-install-tfenv` - Terraform version manager
8. `06-install-tgenv` - Terragrunt version manager
9. `after_install-vim` - Vim plugins (runs after files applied)

## Claude Code Configuration

What lives in `private_dot_claude/` (deployed to `~/.claude/`):

**Reference docs** (loaded into every Claude session):
- `CLAUDE.md` — Global preferences, workflow rules, communication style
- `quality.md` — Engineering standards
- `python.md` — Toolchain rules (pyenv + uv only)
- `token-efficiency.md` — Context management strategies
- `testing.md` — BDD/TDD methodology
- `architecture-guidelines.md` — Design principles
- `development-guidelines.md` — Git workflow, code review culture

**Hooks** (`hooks/`):
- `cleanup-orphaned-processes.sh` — Kill stale subagents on SessionStart/SessionEnd
- `notify.sh` — WSL2-Windows notification on task completion
- `session-end.sh` — Automatic token usage logging to SQLite

**Scripts** (`bin/`):
- `token-log` — Manual token entry
- `token-report` — Usage analytics (7 views)

**Related repos:**
- `~/code/caylent/cae-claude-bestpractices` — MCP servers (aws-docs, pricing, terraform, diagrams), `/scaffold`, `/review-terraform`
- `~/code/caylent/caylent-community-skills` — Compliance, architecture, SOW review skills

**Self-correction:**
- retro plugin — `/retro:error` and `/retro:success` for pattern logging, `/retro:review` for rule generation
- hookify plugin — Guardrail rules (no-skip-tests, no-force-push-main, chezmoi-re-add)
- `chezmoi verify` — Config drift detection (exit 0 = in sync)

## Template Variables

Available via `{{ .chezmoi.* }}`:
- `.chezmoi.os` - "linux", "darwin"
- `.chezmoi.arch` - "amd64", "arm64"
- `.name`, `.email` - From prompted config

## Testing

```bash
docker build -f Dockerfile.test -t dotfiles-test .
docker run --rm dotfiles-test chezmoi apply --verbose
docker run --rm dotfiles-test chezmoi verify
```

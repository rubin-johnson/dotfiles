# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles repo managed with [chezmoi](https://www.chezmoi.io/). Targets WSL2/Debian environments.

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

## Testing

```bash
docker build -f Dockerfile.test -t dotfiles-test .
docker run --rm dotfiles-test chezmoi apply --verbose
docker run --rm dotfiles-test chezmoi verify
```

## Structure

- `dot_*` - Config files applied to ~/
- `private_dot_claude/` - Claude Code config (~/.claude/)
- `.chezmoiscripts/` - Install scripts for tools (apt, pyenv, aws-cli, go, vim)
- `.chezmoi.toml.tmpl` - Prompted config (name, email)
- `.chezmoiignore` - Files to exclude from chezmoi management

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

## Template Variables

Available via `{{ .chezmoi.* }}`:
- `.chezmoi.os` - "linux", "darwin"
- `.chezmoi.arch` - "amd64", "arm64"
- `.name`, `.email` - From prompted config

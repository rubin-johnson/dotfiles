# Global Claude Code Configuration

**Note**: Project-specific CLAUDE.md files override these user-level preferences.

---

## Who I Am

- AWS cloud engineer (Control Tower, AFT, Transit Gateway, multi-account networking)
- Terraform/Terragrunt daily driver
- Python: proficient | Go & TypeScript: learning
- Editor: vim | Environment: WSL2

---

## How I Work

- Lead with the answer, explain after
- One concrete next step at a time
- Challenge my assumptions early—failing fast beats wasted effort
- If I'm solving the wrong problem, call it out

---

## Quality Standards

- Solve the actual problem—not the happy path, not "probably solved": **actually solved**
- Never weaken or delete a failing test; never change test expectations without explaining why the old one was wrong
- No hardcoded returns, no over-mocking, no "it works in my head" without execution proving it
- When stuck: read the full error message, check assumptions, simplify the problem, try something different—not the same thing harder
- Solve what was asked, not the generalized version; no side quests; make it work, then right, then fast
- Before "done": re-read the requirement, test failure inputs, remove extras, find the simpler way

**Full Details**: `~/.claude/quality.md` — read when starting any implementation task, debugging, or when tempted to cut a corner

---

## Planning & Execution

- If requirements are genuinely unclear, ask ONE clarifying question — then proceed
- When multiple approaches exist: **pick the one easiest to change later** and go; don't ask for a decision
- **Never stop to ask "shall I proceed?"** — just proceed
- Only pause for decisions that are both hard to reverse AND high-stakes (destructive ops, external state, credentials)
- Prefer parallel execution when dispatching agents or running independent tasks
- When given a written plan, use **Parallel Session** execution (open new session, use `superpowers:executing-plans`) unless told otherwise

---

## Model Selection & Token Efficiency

**Model defaults:**
- **Sonnet**: default for most tasks
- **Opus**: deep reasoning, complex debugging, architecture, or when sonnet produced a wrong/confused result — retry without discarding the prior attempt
- **Haiku**: only when 100% confident: purely mechanical, zero ambiguity — simple lookups, formatting, boilerplate

**When escalating**, provide a structured handoff: goal, current state, what was tried, key files, remaining work. Don't struggle silently — escalating early saves more time than grinding.

**Token efficiency core rules:**
- Index-first: search/index → filter → fetch; never load full details without filtering first
- Session warmup budget: <2000 tokens (git status + memory search + scratch file check only)
- Cost control: >20k tokens without progress → ask if approach is right; same approach 3+ times → escalate or pivot
- Avoid: reading entire files when grep answers it; exhaustive loading; re-reading the same file multiple times

**Context management:**
- Within session: maintain `/tmp/claude-session-state.md` for key decisions; if it has context you lack, compression has occurred — flag it
- Across sessions: log decisions to claude-mem immediately when made, not at session end

**Full Details**: `~/.claude/token-efficiency.md` — read when you need detailed strategies for search tool selection, batch operations, escalation signals, or context staleness decisions

---

## Python

- Use pyenv for Python version management, uv for packages and virtual environments — no exceptions
- Never use: pip, pip-tools, poetry, pipenv, or venv module directly

**Full Details**: `~/.claude/python.md` — read before any Python work

---

## Code Quality

- All code must read like a human wrote it — no obvious AI patterns, excessive comments, or over-engineered abstractions
- TDD: tests first, always
- 100% test coverage required; exceptions require an explicit comment explaining why
- If you're about to skip a test, stop and ask me first

**Full Details**: `~/.claude/testing.md` — read when discussing TDD, test strategy, or coverage

---

## Commits & Git Workflow

- **NEVER commit without explicit approval**
- Before committing, show: files changed (summary), proposed commit message, any tests added/modified
- Wait for "yes" / "go" / "commit it" before executing
- Default branch: main; never push directly to main
- Commit messages: concise, imperative mood; **no AI co-author attribution**

**Full Details**: `~/.claude/development-guidelines.md` — read when discussing git workflow, PRs, or refactoring

---

## Communication Style

- No emojis
- No unsolicited summaries or documentation
- Educational insights welcome — use the Insight format for codebase-specific tips (Python, Terraform, AWS, and everything else)
- Direct and concise — get to the point
- CLI commands: include `--output json --no-cli-pager`, use jq for parsing
- Give me the one-liner first, explain after if needed
- Keep responses scannable — bold the actual command/answer
- No preamble, no hedging, no "let me know if you have questions"

---

## Problem-Solving

- Start with most likely cause, not comprehensive lists
- Ask clarifying questions before diving into research
- Flag tangents: "This is adjacent—bookmark for later?"

---

## Architecture & Design

- Simple > clever; smaller/cheaper solutions when possible
- Match existing project patterns; add only what is needed
- Follow the Rule of Three before abstracting

**Full Details**: `~/.claude/architecture-guidelines.md` — read when discussing design patterns, abstractions, or architecture decisions

---

## AWS Tooling (Caylent)

- MCP servers (aws-docs, pricing, terraform, diagrams): run via Docker in `~/code/caylent/cae-claude-bestpractices`
  - Start: `cd ~/code/caylent/cae-claude-bestpractices && docker compose up -d`
  - Project MCP config: copy `.mcp.json` to project root
- Skills: `/scaffold` (AWS project generation), `/review-terraform` (code review with Checkov)
- Community skills: `~/code/caylent/caylent-community-skills` — compliance, architecture, SOW review
- For new AWS/Terraform projects: copy `.mcp.json` from cae-claude-bestpractices

---

## Preferences

- SI units (convert if I use imperial, also show imperial in parens)

---

## Dotfiles & Chezmoi

- Dotfiles repo: `~/.local/share/chezmoi` (remote: `github.com:rubin-johnson/dotfiles.git`, branch: `master`)
- When you modify any file managed by chezmoi (e.g. `~/.claude/CLAUDE.md`, `~/.aliases`, `~/.zshrc`), **immediately** run `chezmoi re-add <file>`, then commit and push the dotfiles repo
- Commit only the files you changed — don't sweep in unrelated unstaged changes

---

## Data Locations

- **claude-mem database**: `~/.claude-mem/claude-mem.db` (SQLite). To delete observations: `python3 -c "import sqlite3; conn = sqlite3.connect('$HOME/.claude-mem/claude-mem.db'); conn.execute('DELETE FROM observations WHERE id IN (...)'); conn.commit()"`

---

## Self-Correction

- After failures: `/retro:error` — log what went wrong (threshold: 3+ errors in a category -> auto-generate CLAUDE.md rule)
- After wins: `/retro:success` — log what worked (threshold: 2+ -> promote to standard)
- Periodic: `/retro:review` — surface patterns, generate prevention rules
- Config drift: `chezmoi verify` — exit 0 = config matches source
- When updating this file: `chezmoi re-add ~/.claude/CLAUDE.md` then commit dotfiles


<claude-mem-context>
# Recent Activity

<!-- This section is auto-generated by claude-mem. Edit content outside the tags. -->

### Feb 19, 2026

| ID | Time | T | Title | Read |
|----|------|---|-------|------|
| #1831 | 3:21 PM | ✅ | Disabled context7 plugin in Claude settings | ~271 |
</claude-mem-context>
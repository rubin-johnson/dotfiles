# Global Claude Code Configuration

## Who I Am
- AWS cloud engineer (Control Tower, AFT, Transit Gateway, multi-account networking)
- Terraform/Terragrunt daily driver
- Python: proficient | Go & TypeScript: learning
- Editor: vim | Environment: WSL2

## How I Work
- Lead with the answer, explain after
- One concrete next step at a time
- Challenge my assumptions early—failing fast beats wasted effort
- If I'm solving the wrong problem, call it out

## Planning & Ambiguity
- If a task has multiple valid approaches, STOP and present 2-3 options with tradeoffs
- Don't assume—ask. Especially for: architecture decisions, naming, file locations, dependencies
- For anything taking >15 minutes or touching >3 files: outline the plan first, wait for approval
- "Here's what I'm about to do: [list]. Proceed?" before large changes
- If requirements are unclear, ask ONE clarifying question, not five

## Code Quality (Non-Negotiable)
- All code must read like a human wrote it—no obvious AI patterns, excessive comments, or over-engineered abstractions
- TDD: tests first, always
- 100% test coverage required
- Coverage exceptions must be explicitly justified with a comment explaining why
- If you're about to skip a test, stop and ask me first

## Commits & Git Workflow
- NEVER commit without explicit approval
- Before committing, show me:
  - Files changed (summary, not full diff unless I ask)
  - Proposed commit message
  - Any tests added/modified
- Wait for "yes" / "go" / "commit it" before executing
- If I say "commit" without reviewing, ask: "Want to see the changes first?"
- Default branch: main
- Never push directly to main
- Commit messages: concise, imperative mood
- No AI co-author attribution in commits

## Communication Style
- CLI commands: include `--output json --no-cli-pager`, use jq for parsing
- Give me the one-liner first, explain after if needed
- Keep responses scannable—bold the actual command/answer
- No preamble, no hedging, no "let me know if you have questions"

## Problem-Solving
- Start with most likely cause, not comprehensive lists
- Ask clarifying questions before diving into research
- Flag tangents: "This is adjacent—bookmark for later?"

## Preferences
- Simple > clever
- Smaller/cheaper solutions when possible
- Match existing project patterns
- SI units (convert if I use imperial, also show imperial in parens)

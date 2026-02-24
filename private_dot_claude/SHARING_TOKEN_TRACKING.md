# Sharing Token Tracking System

Three ways to share this token tracking system with colleagues:

---

## Option 1: One-Line Install (Easiest)

Share this command for instant installation:

```bash
curl -fsSL https://raw.githubusercontent.com/rubin-johnson/dotfiles/master/private_dot_claude/install-token-tracking.sh | bash
```

**Or if they prefer to review first:**

```bash
curl -fsSL https://raw.githubusercontent.com/rubin-johnson/dotfiles/master/private_dot_claude/install-token-tracking.sh -o install-token-tracking.sh
cat install-token-tracking.sh  # Review it
bash install-token-tracking.sh
```

**Requirements**: sqlite3 installed

**What it does**:
- Creates `~/.claude/hooks/session-end.sh`
- Creates `~/.claude/bin/token-report` and `token-log`
- Adds aliases to shell config
- Initializes database
- Zero manual configuration needed

---

## Option 2: Direct File Sharing

**Send them these 3 files** from your dotfiles repo:

```
private_dot_claude/hooks/executable_session-end.sh
private_dot_claude/bin/executable_token-report
private_dot_claude/bin/executable_token-log
```

**Installation instructions for recipient:**

```bash
# Create directories
mkdir -p ~/.claude/hooks ~/.claude/bin

# Copy files (they send you the files)
cp session-end.sh ~/.claude/hooks/
cp token-report ~/.claude/bin/
cp token-log ~/.claude/bin/

# Make executable
chmod +x ~/.claude/hooks/session-end.sh
chmod +x ~/.claude/bin/token-report
chmod +x ~/.claude/bin/token-log

# Add aliases to shell config (~/.zshrc or ~/.bashrc)
cat >> ~/.zshrc <<'EOF'

# Claude Code token tracking
alias tokens='~/.claude/bin/token-report'
alias token-log='~/.claude/bin/token-log'
EOF

# Reload shell
source ~/.zshrc

# Initialize database
~/.claude/hooks/session-end.sh

# Install sqlite3 if needed
sudo apt install sqlite3  # Ubuntu/Debian
brew install sqlite3      # macOS
```

---

## Option 3: Documentation Bundle

Share a complete package with docs:

**Create a zip/tarball:**

```bash
cd ~/.claude
tar -czf token-tracking-bundle.tar.gz \
    install-token-tracking.sh \
    TOKEN_TRACKING.md \
    token-efficiency.md \
    hooks/session-end.sh \
    bin/token-report \
    bin/token-log
```

**Send them `token-tracking-bundle.tar.gz` with installation instructions:**

```bash
# Extract
tar -xzf token-tracking-bundle.tar.gz -C ~/

# Run installer
bash ~/.claude/install-token-tracking.sh

# Read documentation
cat ~/.claude/TOKEN_TRACKING.md
```

---

## What They Get

After installation, your colleagues can:

**Log token usage:**
```bash
token-log 45000 "Feature implementation"
```

**View reports:**
```bash
tokens summary          # Overall stats
tokens daily            # Last 30 days
tokens by-category      # Usage by category
tokens by-repo          # Usage by repository
tokens trends           # 7-day rolling average
```

**Query directly:**
```bash
sqlite3 ~/.claude/token-usage.db "SELECT * FROM sessions WHERE date >= '2026-02-01'"
```

---

## Customization Guide for Recipients

**Add custom categories** (edit `~/.claude/hooks/session-end.sh`):

```bash
CATEGORY="general"
case "$WORKING_DIR" in
    *terraform*) CATEGORY="terraform" ;;
    *python*) CATEGORY="python-development" ;;
    *yourproject*) CATEGORY="your-category" ;;  # Add custom categories here
esac
```

**Create custom reports** (edit `~/.claude/bin/token-report`):

```bash
case "$REPORT_TYPE" in
    # Add custom report types
    my-custom-report)
        sqlite3 -column -header "$DB" <<'EOF'
SELECT * FROM sessions WHERE category = 'my-category';
EOF
        ;;
esac
```

---

## Sharing the Token Efficiency Guidelines

**Also share** `~/.claude/token-efficiency.md`:

```bash
# If sharing as standalone doc
cp ~/.claude/token-efficiency.md token-efficiency-guidelines.md

# Or include in bundle (already done in Option 3)
```

This document explains the WHY behind token tracking and provides strategies for efficient usage.

---

## Support & Troubleshooting

**Common issues:**

1. **sqlite3 not found**
   ```bash
   sudo apt install sqlite3  # Ubuntu/Debian
   brew install sqlite3      # macOS
   sudo yum install sqlite   # RHEL/CentOS
   ```

2. **Aliases not working**
   - Check shell config: `~/.zshrc` or `~/.bashrc`
   - Reload: `source ~/.zshrc`

3. **Database not created**
   - Run manually: `~/.claude/hooks/session-end.sh`
   - Check permissions: `ls -la ~/.claude/`

4. **Token counts show as 0**
   - Expected behavior (auto-capture not implemented yet)
   - Use manual logging: `token-log <tokens>`

---

## Repository Link

Full source code and updates:
https://github.com/rubin-johnson/dotfiles

Specific files:
- Installer: `/private_dot_claude/install-token-tracking.sh`
- Hook: `/private_dot_claude/hooks/executable_session-end.sh`
- Report: `/private_dot_claude/bin/executable_token-report`
- Log: `/private_dot_claude/bin/executable_token-log`
- Docs: `/private_dot_claude/TOKEN_TRACKING.md`

---

## Example Email/Message to Colleagues

```
Hey team,

I've built a lightweight token usage tracker for Claude Code sessions
that helps compare strategies and understand usage patterns.

Quick install:
curl -fsSL https://raw.githubusercontent.com/rubin-johnson/dotfiles/master/private_dot_claude/install-token-tracking.sh | bash

Or download and review first from:
https://github.com/rubin-johnson/dotfiles/tree/master/private_dot_claude

After install:
- token-log <count> [notes]  # Log session usage
- tokens summary              # View stats
- tokens by-category          # See where tokens go

Zero config, automatic session tracking, SQLite backend for easy analysis.

Let me know if you have questions!
```

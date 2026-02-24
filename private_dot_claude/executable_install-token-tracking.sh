#!/bin/bash
#
# Token Tracking System Installer
# Usage: bash install-token-tracking.sh
#

set -euo pipefail

echo "=== Claude Code Token Tracking Installer ==="
echo

# Detect shell
SHELL_CONFIG=""
if [ -n "${ZSH_VERSION:-}" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
    echo "Detected: zsh"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
    echo "Detected: bash"
else
    echo "Error: Could not detect shell configuration file"
    exit 1
fi

# Check for sqlite3
if ! command -v sqlite3 &> /dev/null; then
    echo
    echo "sqlite3 is required but not installed."
    echo "Install it with:"
    echo "  Ubuntu/Debian: sudo apt install sqlite3"
    echo "  macOS: brew install sqlite3"
    echo "  RHEL/CentOS: sudo yum install sqlite"
    exit 1
fi

# Create directories
echo
echo "Creating directories..."
mkdir -p ~/.claude/hooks
mkdir -p ~/.claude/bin

# Create session-end hook
echo "Installing session-end hook..."
cat > ~/.claude/hooks/session-end.sh <<'HOOK_EOF'
#!/bin/bash
set -euo pipefail

DB="$HOME/.claude/token-usage.db"

if [ ! -f "$DB" ]; then
    sqlite3 "$DB" <<'EOF'
CREATE TABLE IF NOT EXISTS sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL,
    date TEXT NOT NULL,
    working_dir TEXT,
    git_repo TEXT,
    git_branch TEXT,
    category TEXT,
    tokens_total INTEGER,
    session_duration_seconds INTEGER,
    notes TEXT
);
CREATE INDEX IF NOT EXISTS idx_date ON sessions(date);
CREATE INDEX IF NOT EXISTS idx_category ON sessions(category);
CREATE INDEX IF NOT EXISTS idx_repo ON sessions(git_repo);
EOF
fi

TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S")
DATE=$(date -u +"%Y-%m-%d")
WORKING_DIR=$(pwd)

GIT_REPO=""
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    GIT_REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo '')")
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')
fi

CATEGORY="general"
case "$WORKING_DIR" in
    *terraform*) CATEGORY="terraform" ;;
    *python*) CATEGORY="python-development" ;;
    */go/*) CATEGORY="go-development" ;;
    */typescript*) CATEGORY="typescript-development" ;;
    *.claude*) CATEGORY="claude-config" ;;
esac

TOKENS_TOTAL="${CLAUDE_SESSION_TOKENS:-0}"
SESSION_DURATION="${CLAUDE_SESSION_DURATION:-0}"

sqlite3 "$DB" <<EOF
INSERT INTO sessions (
    timestamp, date, working_dir, git_repo, git_branch,
    category, tokens_total, session_duration_seconds, notes
) VALUES (
    '$TIMESTAMP', '$DATE', '$WORKING_DIR', '$GIT_REPO', '$GIT_BRANCH',
    '$CATEGORY', $TOKENS_TOTAL, $SESSION_DURATION, ''
);
EOF

exit 0
HOOK_EOF

chmod +x ~/.claude/hooks/session-end.sh

# Create token-report script
echo "Installing token-report..."
cat > ~/.claude/bin/token-report <<'REPORT_EOF'
#!/bin/bash
set -euo pipefail

DB="$HOME/.claude/token-usage.db"

if [ ! -f "$DB" ]; then
    echo "No token usage data found. Database will be created after first session."
    exit 1
fi

REPORT_TYPE="${1:-summary}"

case "$REPORT_TYPE" in
    summary)
        echo "=== Token Usage Summary ==="
        echo
        sqlite3 -column -header "$DB" <<'EOF'
SELECT COUNT(*) as total_sessions, SUM(tokens_total) as total_tokens,
       AVG(tokens_total) as avg_tokens_per_session,
       MIN(date) as first_session, MAX(date) as last_session
FROM sessions WHERE tokens_total > 0;
EOF
        ;;
    daily)
        echo "=== Daily Token Usage (Last 30 Days) ==="
        echo
        sqlite3 -column -header "$DB" <<'EOF'
SELECT date, COUNT(*) as sessions, SUM(tokens_total) as total_tokens,
       AVG(tokens_total) as avg_tokens
FROM sessions
WHERE date >= date('now', '-30 days') AND tokens_total > 0
GROUP BY date ORDER BY date DESC;
EOF
        ;;
    weekly)
        echo "=== Weekly Token Usage ==="
        echo
        sqlite3 -column -header "$DB" <<'EOF'
SELECT strftime('%Y-W%W', date) as week, COUNT(*) as sessions,
       SUM(tokens_total) as total_tokens, AVG(tokens_total) as avg_tokens
FROM sessions WHERE tokens_total > 0
GROUP BY week ORDER BY week DESC LIMIT 12;
EOF
        ;;
    by-repo)
        echo "=== Token Usage by Repository ==="
        echo
        sqlite3 -column -header "$DB" <<'EOF'
SELECT git_repo, COUNT(*) as sessions, SUM(tokens_total) as total_tokens,
       AVG(tokens_total) as avg_tokens
FROM sessions WHERE git_repo != '' AND tokens_total > 0
GROUP BY git_repo ORDER BY total_tokens DESC LIMIT 20;
EOF
        ;;
    by-category)
        echo "=== Token Usage by Category ==="
        echo
        sqlite3 -column -header "$DB" <<'EOF'
SELECT category, COUNT(*) as sessions, SUM(tokens_total) as total_tokens,
       AVG(tokens_total) as avg_tokens,
       ROUND(SUM(tokens_total) * 100.0 / (SELECT SUM(tokens_total) FROM sessions WHERE tokens_total > 0), 1) as percentage
FROM sessions WHERE tokens_total > 0
GROUP BY category ORDER BY total_tokens DESC;
EOF
        ;;
    recent)
        echo "=== Recent Sessions (Last 20) ==="
        echo
        sqlite3 -column -header "$DB" <<'EOF'
SELECT timestamp, category, git_repo, tokens_total
FROM sessions WHERE tokens_total > 0
ORDER BY timestamp DESC LIMIT 20;
EOF
        ;;
    trends)
        echo "=== Token Usage Trends (7-day rolling average) ==="
        echo
        sqlite3 -column -header "$DB" <<'EOF'
WITH daily_totals AS (
    SELECT date, SUM(tokens_total) as daily_tokens
    FROM sessions WHERE tokens_total > 0
    GROUP BY date
)
SELECT date, daily_tokens,
       ROUND(AVG(daily_tokens) OVER (
           ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ), 0) as rolling_7day_avg
FROM daily_totals ORDER BY date DESC LIMIT 30;
EOF
        ;;
    *)
        echo "Usage: token-report [summary|daily|weekly|by-repo|by-category|recent|trends]"
        exit 1
        ;;
esac
REPORT_EOF

chmod +x ~/.claude/bin/token-report

# Create token-log script
echo "Installing token-log..."
cat > ~/.claude/bin/token-log <<'LOG_EOF'
#!/bin/bash
set -euo pipefail

DB="$HOME/.claude/token-usage.db"

if [ $# -lt 1 ]; then
    echo "Usage: token-log <tokens> [notes]"
    echo
    echo "Examples:"
    echo "  token-log 45000"
    echo "  token-log 45000 'Feature implementation'"
    exit 1
fi

TOKENS="$1"
NOTES="${2:-}"

LAST_ID=$(sqlite3 "$DB" "SELECT MAX(id) FROM sessions")

if [ -z "$LAST_ID" ]; then
    echo "Error: No sessions found in database"
    exit 1
fi

sqlite3 "$DB" <<EOF
UPDATE sessions
SET tokens_total = $TOKENS, notes = '$NOTES'
WHERE id = $LAST_ID;
EOF

echo "Updated session $LAST_ID with $TOKENS tokens"
sqlite3 -column -header "$DB" "SELECT * FROM sessions WHERE id = $LAST_ID"
LOG_EOF

chmod +x ~/.claude/bin/token-log

# Add aliases to shell config
echo
echo "Adding aliases to $SHELL_CONFIG..."

if ! grep -q "alias tokens=" "$SHELL_CONFIG" 2>/dev/null; then
    cat >> "$SHELL_CONFIG" <<'ALIAS_EOF'

# Claude Code token tracking
alias tokens='~/.claude/bin/token-report'
alias token-log='~/.claude/bin/token-log'
ALIAS_EOF
    echo "Aliases added"
else
    echo "Aliases already exist, skipping"
fi

# Initialize database
echo
echo "Initializing database..."
~/.claude/hooks/session-end.sh || true

echo
echo "=== Installation Complete ==="
echo
echo "Available commands:"
echo "  tokens summary      - View overall statistics"
echo "  tokens daily        - Daily usage (last 30 days)"
echo "  tokens by-category  - Usage by category"
echo "  tokens by-repo      - Usage by repository"
echo "  token-log <count>   - Log token usage for current session"
echo
echo "Reload your shell or run: source $SHELL_CONFIG"
echo
echo "Documentation: ~/.claude/TOKEN_TRACKING.md"

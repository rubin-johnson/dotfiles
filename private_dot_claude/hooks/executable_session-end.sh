#!/bin/bash
#
# Session-end hook: Automatically log token usage
# Runs at the end of every Claude Code session
#

set -euo pipefail

# Database location
DB="$HOME/.claude/token-usage.db"

# Initialize database if it doesn't exist
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

# Capture session context
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S")
DATE=$(date -u +"%Y-%m-%d")
WORKING_DIR=$(pwd)

# Try to get git info
GIT_REPO=""
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    GIT_REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo '')")
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')
fi

# Auto-categorize based on directory/repo
CATEGORY="general"
case "$WORKING_DIR" in
    *terraform*) CATEGORY="terraform" ;;
    *arium_code*) CATEGORY="arium-infrastructure" ;;
    *cc_code*) CATEGORY="crowncastle-infrastructure" ;;
    *.claude*) CATEGORY="claude-config" ;;
    *python*) CATEGORY="python-development" ;;
    */go/*) CATEGORY="go-development" ;;
    */typescript*) CATEGORY="typescript-development" ;;
esac

# Get token usage from environment if available
# Note: Claude Code may expose these via env vars - adjust as needed
TOKENS_TOTAL="${CLAUDE_SESSION_TOKENS:-0}"
SESSION_DURATION="${CLAUDE_SESSION_DURATION:-0}"

# Log to database
sqlite3 "$DB" <<EOF
INSERT INTO sessions (
    timestamp,
    date,
    working_dir,
    git_repo,
    git_branch,
    category,
    tokens_total,
    session_duration_seconds,
    notes
) VALUES (
    '$TIMESTAMP',
    '$DATE',
    '$WORKING_DIR',
    '$GIT_REPO',
    '$GIT_BRANCH',
    '$CATEGORY',
    $TOKENS_TOTAL,
    $SESSION_DURATION,
    ''
);
EOF

# Nudge retro review if enough unreviewed entries have accumulated
RETRO_DB="$HOME/.retro/retro.db"
if [ -f "$RETRO_DB" ]; then
    LAST_REVIEWED=$(sqlite3 "$RETRO_DB" "SELECT value FROM metadata WHERE key = 'last_reviewed_at'" 2>/dev/null || echo "")
    if [ -n "$LAST_REVIEWED" ]; then
        UNREVIEWED=$(sqlite3 "$RETRO_DB" "SELECT COUNT(*) FROM entries WHERE created_at > '$LAST_REVIEWED'" 2>/dev/null || echo "0")
    else
        UNREVIEWED=$(sqlite3 "$RETRO_DB" "SELECT COUNT(*) FROM entries" 2>/dev/null || echo "0")
    fi
    if [ "$UNREVIEWED" -ge 5 ] 2>/dev/null; then
        echo "retro: $UNREVIEWED unreviewed entries — run /retro:review" >&2
    fi
fi

# Silent success - no output unless there's an error
exit 0

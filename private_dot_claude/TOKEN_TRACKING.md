# Automated Token Usage Tracking

**Status**: Automatically captures session metadata. Manual token logging required.

## Quick Reference

```bash
# At end of session, log tokens
token-log 54629 "Brief description of work"

# View reports
tokens summary          # Overall stats
tokens daily            # Last 30 days
tokens by-category      # Usage by category
tokens by-repo          # Usage by repository
tokens trends           # 7-day rolling average

# Direct SQL query
sqlite3 ~/.claude/token-usage.db "SELECT * FROM sessions ORDER BY date DESC LIMIT 10"
```

## How It Works

1. **Session-End Hook** (`~/.claude/hooks/session-end.sh`)
   - Runs automatically when each session ends
   - Captures: timestamp, working directory, git repo, category, token usage
   - Stores in SQLite database (`~/.claude/token-usage.db`)
   - Zero human input required

2. **Auto-Categorization**
   - Based on working directory patterns
   - Categories: terraform, arium-infrastructure, crowncastle-infrastructure, python-development, etc.
   - Easily extendable in hook script

3. **Storage Schema**
   ```sql
   CREATE TABLE sessions (
       id INTEGER PRIMARY KEY,
       timestamp TEXT,           -- UTC timestamp
       date TEXT,                -- YYYY-MM-DD
       working_dir TEXT,         -- Full path
       git_repo TEXT,            -- Repository name
       git_branch TEXT,          -- Current branch
       category TEXT,            -- Auto-assigned category
       tokens_total INTEGER,     -- Total tokens used
       session_duration_seconds INTEGER,
       notes TEXT                -- Optional manual notes
   );
   ```

## Usage

### View Reports

```bash
# Overall summary
token-report summary

# Daily usage (last 30 days)
token-report daily

# Weekly trends
token-report weekly

# Usage by repository
token-report by-repo

# Usage by category
token-report by-category

# Recent sessions
token-report recent

# 7-day rolling average (trends)
token-report trends
```

### Manual SQL Queries

```bash
# Custom query
sqlite3 ~/.claude/token-usage.db "SELECT * FROM sessions WHERE date >= '2026-02-01'"

# Token usage for specific repo
sqlite3 ~/.claude/token-usage.db "
SELECT date, SUM(tokens_total)
FROM sessions
WHERE git_repo = 'terraform-aws-ec2-module'
GROUP BY date
"
```

### Add Note to Last Session

```bash
sqlite3 ~/.claude/token-usage.db "
UPDATE sessions
SET notes = 'CPE-5208 module updates'
WHERE id = (SELECT MAX(id) FROM sessions)
"
```

## Comparing Strategies

### Before/After Analysis

When testing a new token-saving strategy:

1. **Baseline period** - Let it run for 1-2 weeks naturally
2. **Implement strategy** - Make your changes
3. **Comparison period** - Another 1-2 weeks
4. **Analyze**:
   ```sql
   -- Compare periods
   SELECT
       CASE
           WHEN date < '2026-03-01' THEN 'before'
           ELSE 'after'
       END as period,
       COUNT(*) as sessions,
       AVG(tokens_total) as avg_tokens,
       SUM(tokens_total) as total_tokens
   FROM sessions
   WHERE date >= '2026-02-15'
   GROUP BY period;
   ```

### Strategy-Specific Tracking

Tag sessions with strategy notes:

```bash
# After implementing a new strategy
sqlite3 ~/.claude/token-usage.db "
UPDATE sessions
SET notes = 'using-index-first-strategy'
WHERE date >= date('now')
"
```

Then query by strategy:
```sql
SELECT
    notes,
    COUNT(*) as sessions,
    AVG(tokens_total) as avg_tokens
FROM sessions
WHERE notes LIKE '%strategy%'
GROUP BY notes;
```

## Manual Token Logging (Current Workflow)

**Status**: Automatic token capture is not yet working. Use manual logging for now.

**At the end of each session**, note the token count from the last system warning and log it:

```bash
# View current token usage in session (look for system-reminder with token count)
# Then log it manually:
token-log <tokens> [optional notes]

# Examples:
token-log 54629
token-log 54629 "Setting up token tracking system"
token-log 125000 "CPE-5208 bulk updates across 40 repos"
```

The session-end hook still captures:
- Timestamp, working directory, git repo/branch
- Auto-categorization
- Creates database entry automatically

You just need to add the token count afterward.

**Future enhancement**: Parse session transcripts or API responses to automate this fully.

## Maintenance

### Backup Database

```bash
cp ~/.claude/token-usage.db ~/.claude/token-usage.db.backup
```

### View All Data

```bash
sqlite3 -column -header ~/.claude/token-usage.db "SELECT * FROM sessions"
```

### Clear Old Data

```bash
# Delete sessions older than 90 days
sqlite3 ~/.claude/token-usage.db "DELETE FROM sessions WHERE date < date('now', '-90 days')"
sqlite3 ~/.claude/token-usage.db "VACUUM"
```

## Integration with claude-mem

Token tracking is separate from claude-mem but complementary:

- **claude-mem**: What you learned, decisions made, context preservation
- **token-tracking**: How much it cost, efficiency metrics, trends

Both help optimize your workflow from different angles.

## Future Enhancements

Possible additions if needed:
- Tool-level tracking (parse which tools used most tokens)
- Agent/subagent cost breakdown
- Real-time budget alerts
- Grafana dashboard integration
- Cost estimates ($$$) based on model pricing

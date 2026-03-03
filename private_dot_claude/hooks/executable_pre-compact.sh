#!/usr/bin/env bash
# PreCompact hook: archive current session as HTML before context compaction

set -euo pipefail

input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

if [[ -z "$transcript_path" || ! -f "$transcript_path" ]]; then
  exit 0
fi

output_dir="$HOME/.claude/transcripts"
mkdir -p "$output_dir"

uvx claude-code-transcripts json "$transcript_path" -o "$output_dir" -a 2>/dev/null || true

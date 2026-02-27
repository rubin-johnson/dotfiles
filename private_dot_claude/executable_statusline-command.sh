#!/usr/bin/env bash
# Claude Code status line

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Shorten home directory
display_cwd="${cwd/#$HOME/\~}"

# Format token count (k)
total_tokens=$(( total_in + total_out ))
if (( total_tokens >= 1000000 )); then
  tokens_fmt="$(( total_tokens / 1000000 )).$(( (total_tokens % 1000000) / 100000 ))M"
elif (( total_tokens >= 1000 )); then
  tokens_fmt="$(( total_tokens / 1000 ))k"
else
  tokens_fmt="${total_tokens}"
fi

# Colors
RST=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
CYAN=$'\033[36m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
RED=$'\033[31m'

# Context color by threshold
ctx_part=""
if [[ -n "$used_pct" ]]; then
  pct_int=${used_pct%.*}
  if (( pct_int >= 80 )); then
    ctx_c="$RED"
  elif (( pct_int >= 50 )); then
    ctx_c="$YELLOW"
  else
    ctx_c="$GREEN"
  fi
  ctx_part="${DIM}|${RST} ${ctx_c}ctx:${pct_int}%${RST} "
fi

echo "${BOLD}${CYAN}${display_cwd}${RST}  ${YELLOW}${model}${RST}  ${ctx_part}${DIM}|${RST} ${tokens_fmt}"

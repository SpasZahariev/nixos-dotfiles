#!/usr/bin/env bash
# cycle_window.sh - Generic focus-switcher/cycler for any app.
# Usage: cycle_window.sh <class-substring> <launch-command> [args...]
# Example: cycle_window.sh ghostty ghostty
#          cycle_window.sh brave-browser brave
#
# Behaviour:
# - Finds all mapped windows whose class/initialClass contains
#   <class-substring> (case-insensitive), sorted by workspace id, then address.
# - No match focused -> focus the first one.
# - Focused window is a match -> focus the next one (wraps around).
# - Focusing uses `focuswindow address:...`, which auto-switches to the
#   window's workspace/monitor, then centers the mouse in the window.
# - No windows open -> spawns the launch command on the workspace visible
#   where the cursor is, waits for it, then focuses + centers the mouse.
# - Stateless: the next target is derived from the currently focused window,
#   so opening/closing windows never leaves stale state behind.
set -euo pipefail

MATCH=${1:?Usage: cycle_window.sh <class-substring> <launch-command> [args...]}
shift
if [ "$#" -eq 0 ]; then
  echo "Usage: cycle_window.sh <class-substring> <launch-command> [args...]" >&2
  exit 1
fi
MATCH_LOWER=$(printf '%s' "$MATCH" | tr '[:upper:]' '[:lower:]')
LAUNCH_STR="$*"

list_matches() {
  # Prints one line per matching window:
  # "<address> <at_x> <at_y> <size_w> <size_h>", sorted deterministically.
  # $1 = clients JSON, $2 = newline-separated addresses to exclude (optional).
  local clients_json=$1
  local exclude_addrs=${2:-}
  printf '%s' "$clients_json" | jq -r \
    --arg match "$MATCH_LOWER" \
    --arg exclude "$exclude_addrs" '
    ($exclude | split("\n") | map(select(length > 0))) as $seen
    | [sort_by(.workspace.id, .address)
      | .[]
      | select(
          (((.class // "") | ascii_downcase | contains($match))
            or ((.initialClass // "") | ascii_downcase | contains($match)))
          and .mapped == true
          and ((.workspace.name // "") | startswith("special") | not)
          and ((.address as $a | $seen | index($a) | not))
        )
      | "\(.address) \(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"]
    | .[]
  '
}

focus_and_center() {
  # $1 = "<address> <at_x> <at_y> <size_w> <size_h>"
  local target_addr at_x at_y size_w size_h cx cy
  read -r target_addr at_x at_y size_w size_h <<< "$1"
  cx=$(( at_x + size_w / 2 ))
  cy=$(( at_y + size_h / 2 ))
  hyprctl --batch "dispatch focuswindow address:${target_addr}; dispatch movecursor ${cx} ${cy}"
}

CLIENTS_JSON=$(hyprctl clients -j)

mapfile -t TERMS < <(list_matches "$CLIENTS_JSON" || true)

if [ "${#TERMS[@]}" -eq 0 ]; then
  BEFORE_ADDRS=$(printf '%s' "$CLIENTS_JSON" | jq -r '.[].address')

  CURSOR_RAW=$(hyprctl cursorpos)
  CURSOR_X=$(printf '%s' "$CURSOR_RAW" | awk -F'[ ,]+' '{print $1}')
  CURSOR_Y=$(printf '%s' "$CURSOR_RAW" | awk -F'[ ,]+' '{print $2}')

  TARGET_WS=$(hyprctl monitors -j | jq -r --argjson cx "$CURSOR_X" --argjson cy "$CURSOR_Y" '
    (first(.[] | select(.x <= $cx and $cx < (.x + .width) and .y <= $cy and $cy < (.y + .height)) | .activeWorkspace.id))
    // (first(.[] | select(.focused == true) | .activeWorkspace.id))
    // 1
  ')

  # shellcheck disable=SC2086
  hyprctl dispatch exec "[workspace ${TARGET_WS}] ${LAUNCH_STR}"

  for _ in $(seq 1 30); do
    sleep 0.2
    NEW_TERM=$(list_matches "$(hyprctl clients -j)" "$BEFORE_ADDRS" | head -n 1 || true)
    if [ -n "$NEW_TERM" ]; then
      focus_and_center "$NEW_TERM"
      exit 0
    fi
  done
  exit 0
fi

ACTIVE_ADDR=$(hyprctl activewindow -j | jq -r '.address // empty')

TARGET_INDEX=0
if [ -n "$ACTIVE_ADDR" ]; then
  for i in "${!TERMS[@]}"; do
    ADDR=${TERMS[$i]%% *}
    if [ "$ADDR" = "$ACTIVE_ADDR" ]; then
      TARGET_INDEX=$(( (i + 1) % ${#TERMS[@]} ))
      break
    fi
  done
fi

focus_and_center "${TERMS[$TARGET_INDEX]}"

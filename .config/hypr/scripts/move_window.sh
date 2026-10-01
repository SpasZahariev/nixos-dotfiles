#!/usr/bin/env bash

# move_window.sh - Move active window stepwise up/down, then +/-3 workspaces
# Usage: move_window.sh k|up|j|down
#
# Workspace layout (3 monitors, grouped by 3):
#   HDMI-A-1 (left)   -> 1, 4, 7, ...
#   DP-1     (middle) -> 2, 5, 8, ...
#   DP-2     (right)  -> 3, 6, 9, ...
#
# Behavior for k/up (+3) and j/down (-3):
#   1. Try a normal directional move inside the current workspace
#      (hyprctl dispatch movewindow u/d). This steps the window
#      through splits until it reaches the top/bottom edge.
#   2. If the window did not move (already at the edge), move it to
#      the workspace +3 (up) or -3 (down) away, staying on the same
#      monitor column. Lower bound is clamped to the first group
#      (1, 2 or 3 depending on the monitor column).

set -euo pipefail

DIR=${1:-}

case "$DIR" in
    k|K|up|Up|UP)
        MOVE="u"
        DELTA=3
        ;;
    j|J|down|Down|DOWN)
        MOVE="d"
        DELTA=-3
        ;;
    *)
        echo "Usage: $0 k|up|j|down" >&2
        exit 1
        ;;
esac

ACTIVE_JSON=$(hyprctl activewindow -j)

# No active window (empty workspace) - nothing to do
if [ -z "$ACTIVE_JSON" ] || [ "$ACTIVE_JSON" = "{}" ] || [ "$ACTIVE_JSON" = "null" ]; then
    exit 0
fi

IS_FLOATING=$(echo "$ACTIVE_JSON" | jq -r '.floating // false')
WS_BEFORE=$(echo "$ACTIVE_JSON" | jq -r '.workspace.id')

move_to_target_workspace() {
    local current=$1
    local target=$(( current + DELTA ))
    # Clamp lower bound to the same monitor column in the first group:
    # col 1 -> min 1, col 2 -> min 2, col 3 -> min 3
    if [ "$target" -lt 1 ]; then
        target=$(( (current - 1) % 3 + 1 ))
    fi
    hyprctl dispatch movetoworkspace "$target" >/dev/null
}

# Floating / fullscreen windows have no tiled position to step through,
# so go straight to the +/-3 workspace.
if [ "$IS_FLOATING" = "true" ]; then
    move_to_target_workspace "$WS_BEFORE"
    exit 0
fi

X_BEFORE=$(echo "$ACTIVE_JSON" | jq -r '.at[0]')
Y_BEFORE=$(echo "$ACTIVE_JSON" | jq -r '.at[1]')

hyprctl dispatch movewindow "$MOVE" >/dev/null
# Give Hyprland a moment to apply the move before re-querying
sleep 0.05

AFTER_JSON=$(hyprctl activewindow -j)
if [ -z "$AFTER_JSON" ] || [ "$AFTER_JSON" = "{}" ] || [ "$AFTER_JSON" = "null" ]; then
    exit 0
fi

X_AFTER=$(echo "$AFTER_JSON" | jq -r '.at[0]')
Y_AFTER=$(echo "$AFTER_JSON" | jq -r '.at[1]')
WS_AFTER=$(echo "$AFTER_JSON" | jq -r '.workspace.id')

# If position and workspace are unchanged, the window was already at the
# edge - jump it +/-3 workspaces on the same monitor column.
if [ "$X_BEFORE" = "$X_AFTER" ] && [ "$Y_BEFORE" = "$Y_AFTER" ] && [ "$WS_BEFORE" = "$WS_AFTER" ]; then
    move_to_target_workspace "$WS_BEFORE"
fi

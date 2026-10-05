#!/usr/bin/env bash

# move_focus.sh - Focus stepwise up/down, then +/-3 workspaces
# Usage: move_focus.sh k|up|j|down
#
# Workspace layout (3 monitors, grouped by 3):
#   HDMI-A-1 (left)   -> 1, 4, 7, ...
#   DP-1     (middle) -> 2, 5, 8, ...
#   DP-2     (right)  -> 3, 6, 9, ...
#
# Mirrors move_window.sh, but for focus:
#   1. Try a normal directional focus inside the current workspace
#      (hyprctl dispatch movefocus u/d). This steps through splits
#      until it reaches the top/bottom edge. Note: movefocus wraps
#      around inside the workspace, so an address change alone does
#      not prove we moved in the requested direction - we compare
#      window centers to detect the wrap.
#   2. If focus did not move in the requested direction (already at
#      the edge, or movefocus wrapped to the opposite side), switch
#      to the workspace +3 (up/k) or -3 (down/j) away, staying on
#      the same monitor column, and focus the extreme window there:
#        up/k   -> bottom window of target (largest y)
#        down/j -> top window of target (smallest y)
#      Lower bound is clamped to the first group (1, 2 or 3 depending
#      on the monitor column), matching move_window.sh.

set -euo pipefail

DIR=${1:-}

case "$DIR" in
    k|K|up|Up|UP)
        MOVE="u"
        DELTA=3
        EDGE="top"
        ;;
    j|J|down|Down|DOWN)
        MOVE="d"
        DELTA=-3
        EDGE="bottom"
        ;;
    *)
        echo "Usage: $0 k|up|j|down" >&2
        exit 1
        ;;
esac

current_workspace_id() {
    hyprctl activeworkspace -j | jq -r '.id'
}

focus_extreme_in_workspace() {
    local target=$1
    local edge=$2
    local clients_json
    clients_json=$(hyprctl clients -j)

    local picked
    if [ "$edge" = "bottom" ]; then
        # Came from the bottom going down -> land on the top window
        picked=$(printf '%s' "$clients_json" | jq -r --argjson ws "$target" '
            [ .[]
              | select(.workspace.id == $ws
                  and .mapped == true
                  and ((.workspace.name // "") | startswith("special") | not))
            ]
            | sort_by(.at[1], .at[0])
            | if length == 0 then empty
              else .[0] | "\(.address) \(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"
              end
        ')
    else
        # Came from the top going up -> land on the bottom window
        picked=$(printf '%s' "$clients_json" | jq -r --argjson ws "$target" '
            [ .[]
              | select(.workspace.id == $ws
                  and .mapped == true
                  and ((.workspace.name // "") | startswith("special") | not))
            ]
            | sort_by(.at[1], .at[0])
            | if length == 0 then empty
              else .[-1] | "\(.address) \(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"
              end
        ')
    fi

    if [ -z "${picked:-}" ]; then
        return 1
    fi

    local addr at_x at_y size_w size_h cx cy
    read -r addr at_x at_y size_w size_h <<< "$picked"
    cx=$(( at_x + size_w / 2 ))
    cy=$(( at_y + size_h / 2 ))
    hyprctl --batch "dispatch workspace $target; dispatch focuswindow address:${addr}; dispatch movecursor ${cx} ${cy}" >/dev/null
    return 0
}

jump_to_target_workspace() {
    local current=$1
    local target=$(( current + DELTA ))
    # Clamp lower bound to the same monitor column in the first group:
    # col 1 -> min 1, col 2 -> min 2, col 3 -> min 3
    if [ "$target" -lt 1 ]; then
        target=$(( (current - 1) % 3 + 1 ))
    fi
    if ! focus_extreme_in_workspace "$target" "$EDGE"; then
        # Target has no windows - still switch there
        hyprctl dispatch workspace "$target" >/dev/null
    fi
}

ACTIVE_JSON=$(hyprctl activewindow -j)

# No active window (empty workspace) - just jump +/-3 workspaces
if [ -z "$ACTIVE_JSON" ] || [ "$ACTIVE_JSON" = "{}" ] || [ "$ACTIVE_JSON" = "null" ]; then
    jump_to_target_workspace "$(current_workspace_id)"
    exit 0
fi

ADDR_BEFORE=$(echo "$ACTIVE_JSON" | jq -r '.address')
WS_BEFORE=$(echo "$ACTIVE_JSON" | jq -r '.workspace.id')
AT_Y_BEFORE=$(echo "$ACTIVE_JSON" | jq -r '.at[1]')
SIZE_H_BEFORE=$(echo "$ACTIVE_JSON" | jq -r '.size[1]')
CY_BEFORE=$(( AT_Y_BEFORE + SIZE_H_BEFORE / 2 ))

hyprctl dispatch movefocus "$MOVE" >/dev/null
# Give Hyprland a moment to apply the focus change before re-querying
sleep 0.05

AFTER_JSON=$(hyprctl activewindow -j)
if [ -z "$AFTER_JSON" ] || [ "$AFTER_JSON" = "{}" ] || [ "$AFTER_JSON" = "null" ]; then
    exit 0
fi

ADDR_AFTER=$(echo "$AFTER_JSON" | jq -r '.address')
WS_AFTER=$(echo "$AFTER_JSON" | jq -r '.workspace.id')

# movefocus switched workspace on its own - accept it
if [ "$WS_BEFORE" != "$WS_AFTER" ]; then
    exit 0
fi

# Same window - definitely at the edge
if [ "$ADDR_BEFORE" = "$ADDR_AFTER" ]; then
    jump_to_target_workspace "$WS_BEFORE"
    exit 0
fi

# Address changed but movefocus wraps inside the workspace
# (e.g. bottom + j lands on top of the SAME workspace).
# Only accept the move if the center actually travelled
# in the requested direction.
AT_Y_AFTER=$(echo "$AFTER_JSON" | jq -r '.at[1]')
SIZE_H_AFTER=$(echo "$AFTER_JSON" | jq -r '.size[1]')
CY_AFTER=$(( AT_Y_AFTER + SIZE_H_AFTER / 2 ))

if [ "$MOVE" = "d" ]; then
    if [ "$CY_AFTER" -gt "$CY_BEFORE" ]; then
        exit 0
    fi
else
    if [ "$CY_AFTER" -lt "$CY_BEFORE" ]; then
        exit 0
    fi
fi

# Wrapped around - jump +/-3 workspaces on the same monitor column.
# Re-focus the window we started from first is unnecessary:
# jump_to_target_workspace switches workspace and focuses the
# extreme window there directly.
jump_to_target_workspace "$WS_BEFORE"

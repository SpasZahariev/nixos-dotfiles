#!/usr/bin/env bash

# shift_workspaces.sh - Shift all monitors by one workspace group (+3 or -3)
# Usage: shift_workspaces.sh up|down
#
# Workspace groups: (1,2,3), (4,5,6), (7,8,9), ...
#   HDMI-A-1 always gets the base workspace (1, 4, 7, ...)
#   DP-1     always gets base+1              (2, 5, 8, ...)
#   DP-2     always gets base+2              (3, 6, 9, ...)
#
# Edge cases handled:
#   - Won't go below workspace group (1,2,3)
#   - Creates non-existent workspaces on the correct monitor
#   - Moves existing workspaces to the appropriate monitor if they're on the wrong one

DIRECTION=$1

# Monitor order must match the workspace assignment order in hyprland.conf
MONITORS=("HDMI-A-1" "DP-1" "DP-2")

# Get monitor data
MONITOR_JSON=$(hyprctl monitors -j)

# Get current workspace on the first monitor to determine which group we're in
CURRENT_BASE=$(echo "$MONITOR_JSON" | jq -r '.[] | select(.name == "HDMI-A-1") | .activeWorkspace.id')

# Snap to the nearest group base (in case things got out of sync)
# Group 0 = ws 1,2,3 | Group 1 = ws 4,5,6 | etc.
GROUP=$(( (CURRENT_BASE - 1) / 3 ))
CURRENT_BASE=$(( GROUP * 3 + 1 ))

# Get the currently focused monitor to restore focus later
FOCUSED_MON=$(echo "$MONITOR_JSON" | jq -r '.[] | select(.focused == true) | .name')

if [ "$DIRECTION" = "up" ]; then
    NEW_BASE=$(( CURRENT_BASE + 3 ))
elif [ "$DIRECTION" = "down" ]; then
    NEW_BASE=$(( CURRENT_BASE - 3 ))
    if [ "$NEW_BASE" -lt 1 ]; then
        exit 0  # Already at the lowest group, nothing to do
    fi
else
    echo "Usage: $0 up|down"
    exit 1
fi

# Calculate target workspaces
WS=()
for i in 0 1 2; do
    WS+=($((NEW_BASE + i)))
done

# Build batch command:
# 1. Move existing workspaces to correct monitors
#    (handles the case where a workspace exists but is on the wrong monitor)
# 2. Focus each monitor and switch to the target workspace
#    (creates the workspace on that monitor if it doesn't exist yet)
# 3. Restore focus to the originally focused monitor
BATCH=""
for i in 0 1 2; do
    BATCH+="dispatch moveworkspacetomonitor ${WS[$i]} ${MONITORS[$i]}; "
done
for i in 0 1 2; do
    BATCH+="dispatch focusmonitor ${MONITORS[$i]}; "
    BATCH+="dispatch workspace ${WS[$i]}; "
done
BATCH+="dispatch focusmonitor $FOCUSED_MON"

hyprctl --batch "$BATCH"

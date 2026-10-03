#!/usr/bin/env bash

# Workspace 1 on left monitor
hyprctl dispatch workspace 1
hyprctl dispatch exec brave
sleep 0.2 # since the focus change happens faster than the app start

# Workspace 2 on main monitor
hyprctl dispatch workspace 2
sleep 0.2 # since the focus change happens faster than the app start

# Workspace 3 on right monitor
hyprctl dispatch workspace 3
hyprctl dispatch exec ghostty
sleep 0.2 # since the focus change happens faster than the app start

# Workspace 4 on main monitor (same as workspace 2)
# hyprctl dispatch workspace 4
#
# # Focus workspace 2 (main monitor)
# hyprctl dispatch workspace 2

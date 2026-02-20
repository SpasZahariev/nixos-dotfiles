#!/usr/bin/env bash

pkill -SIGTERM brave

# Close all windows gracefully
hyprctl clients -j | jq -r '.[].address' | while read addr; do
  # hyprctl dispatch closewindow address:$addr
  hyprctl dispatch killwindow address:$addr
done

# Wait for windows to close
sleep 3

systemctl poweroff

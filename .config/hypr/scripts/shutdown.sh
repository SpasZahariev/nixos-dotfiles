#!/usr/bin/env bash

# Close all windows gracefully
hyprctl clients -j | jq -r '.[].address' | while read addr; do
  hyprctl dispatch closewindow address:$addr
done

# Wait for windows to close
sleep 2

systemctl poweroff

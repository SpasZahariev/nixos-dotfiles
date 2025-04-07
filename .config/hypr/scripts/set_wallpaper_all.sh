#!/usr/bin/env bash

# === Usage: ./set-wallpaper-all.sh /path/to/image.jpg ===

# IMAGE="$1"
# Get absolute path to image *from current directory*
IMAGE="$(realpath "$1")"

# List of your monitor names
MONITORS=("HDMI-A-1" "DP-1" "DP-2")

# Check if the image exists
if [ ! -f "$IMAGE" ]; then
  echo "Error: '$IMAGE' is not a valid file."
  exit 1
fi

# Reload hyprpaper
hyprctl hyprpaper unload all

# Preload and apply the wallpaper to all monitors
for MONITOR in "${MONITORS[@]}"; do
  echo "Setting $IMAGE on $MONITOR"
  hyprctl hyprpaper preload "$IMAGE"
  hyprctl hyprpaper wallpaper "$MONITOR,$IMAGE"
done


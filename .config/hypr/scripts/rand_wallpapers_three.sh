#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/wallpapers"

# Get all connected monitor names
MONITORS=($(hyprctl monitors -j | jq -r '.[].name'))

# Get list of all wallpapers
WALLPAPERS=($(find "$WALLPAPER_DIR" -type f))

# Shuffle wallpapers
SHUFFLED_WALLS=($(printf "%s\n" "${WALLPAPERS[@]}" | shuf))

# Make sure we have enough wallpapers
if [ "${#SHUFFLED_WALLS[@]}" -lt "${#MONITORS[@]}" ]; then
    echo "Not enough wallpapers for all monitors!"
    exit 1
fi

# Reload hyprpaper and apply one wallpaper per monitor
hyprctl hyprpaper unload all

for i in "${!MONITORS[@]}"; do
    MONITOR="${MONITORS[$i]}"
    WALL="${SHUFFLED_WALLS[$i]}"
    hyprctl hyprpaper preload "$WALL"
    hyprctl hyprpaper wallpaper "$MONITOR,$WALL"
done


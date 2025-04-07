#!/usr/bin/env bash

# === Config ===
WALLPAPER_DIR="$HOME/dotfiles/wallpapers"
WIDE_WALLPAPER_DIR="$HOME/dotfiles/wallpapers/wide"

MONITORS=(
  "HDMI-A-1"
  "DP-1"
  "DP-2"
)

# === Functions ===

get_random_wallpaper() {
  local dir="$1"
  find "$dir" -type f | shuf -n 1
}

# === Main ===

# Check for required wallpaper files
if [ ! -d "$WALLPAPER_DIR" ] || [ ! -d "$WIDE_WALLPAPER_DIR" ]; then
  echo "Wallpaper directories not found!"
  exit 1
fi

# Select wallpapers
declare -A WALLPAPERS
WALLPAPERS["DP-1"]="$(get_random_wallpaper "$WIDE_WALLPAPER_DIR")"
WALLPAPERS["HDMI-A-1"]="$(get_random_wallpaper "$WALLPAPER_DIR")"
WALLPAPERS["DP-2"]="$(get_random_wallpaper "$WALLPAPER_DIR")"

# Reload hyprpaper and apply
hyprctl hyprpaper unload all

for MONITOR in "${MONITORS[@]}"; do
  WALL="${WALLPAPERS[$MONITOR]}"
  echo "Setting wallpaper for $MONITOR: $WALL"
  hyprctl hyprpaper preload "$WALL"
  hyprctl hyprpaper wallpaper "$MONITOR,$WALL"
done


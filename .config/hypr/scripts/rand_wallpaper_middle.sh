# #!/usr/bin/env bash

# === Config ===
WIDE_WALLPAPER_DIR="$HOME/dotfiles/wallpapers/wide"

MONITOR="DP-1"


# === Functions ===

get_random_wallpaper() {
  local dir="$1"
  find "$dir" -type f | shuf -n 1
}

# === Main ===

# Reload hyprpaper and apply
hyprctl hyprpaper unload all

WALL="$(get_random_wallpaper "$WIDE_WALLPAPER_DIR")"
echo "Setting wallpaper for $MONITOR: $WALL"
hyprctl hyprpaper preload "$WALL"
hyprctl hyprpaper wallpaper "$MONITOR,$WALL"



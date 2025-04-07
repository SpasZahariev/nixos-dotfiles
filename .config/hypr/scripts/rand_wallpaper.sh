# #!/usr/bin/env bash
#
# ### SHOULD put one wallpaper on all three monitors ###

# === Config ===
WIDE_WALLPAPER_DIR="$HOME/dotfiles/wallpapers/wide"
CURRENT_WALL=$(hyprctl hyprpaper listloaded)

MONITORS=(
  "HDMI-A-1"
  "DP-1"
  "DP-2"
)

# === Functions ===

get_random_wallpaper() {
  local dir="$1"
  find "$dir" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1
}

# === Main ===

# Reload hyprpaper and apply
hyprctl hyprpaper unload all

WALL="$(get_random_wallpaper "$WIDE_WALLPAPER_DIR")"
for MONITOR in "${MONITORS[@]}"; do
  echo "Setting wallpaper for $MONITOR: $WALL"
  hyprctl hyprpaper preload "$WALL"
  hyprctl hyprpaper wallpaper "$MONITOR,$WALL"
done

# #!/usr/bin/env bash
#
# ### SHOULD loop through my wallpapers and put one wallpaper on all three monitors ###

# === Config ===
WIDE_WALLPAPER_DIR="$HOME/dotfiles/wallpapers/wide"
CURRENT_WALL=$(hyprctl hyprpaper listloaded)

MONITORS=(
  "HDMI-A-1"
  "DP-1"
  "DP-2"
)

# === Functions ===

# Get the next wallpaper in the directory
get_next_wallpaper() {
  local dir="$1"
  local current_wall="$2"

  # Get all wallpapers in the directory and sort them
  local wallpapers
  wallpapers=$(find "$dir" -type f | sort)

  # Find the next wallpaper after the current one
  local next_wallpaper
  next_wallpaper=""
  found_current=false

  # Iterate through the wallpapers
  for wallpaper in $wallpapers; do
    if [[ "$found_current" == true ]]; then
      next_wallpaper="$wallpaper"
      break
    fi

    if [[ "$wallpaper" == "$current_wall" ]]; then
      found_current=true
    fi
  done

  # If no next wallpaper was found (i.e., we were at the end), start from the first one
  if [[ -z "$next_wallpaper" ]]; then
    next_wallpaper=$(echo "$wallpapers" | head -n 1)
  fi

  echo "$next_wallpaper"
}

# === Main ===

# Reload hyprpaper and apply
hyprctl hyprpaper unload all

# Get the next wallpaper to apply
NEXT_WALL=$(get_next_wallpaper "$WIDE_WALLPAPER_DIR" "$CURRENT_WALL")

for MONITOR in "${MONITORS[@]}"; do
  echo "Setting wallpaper for $MONITOR: $NEXT_WALL"
  hyprctl hyprpaper preload "$NEXT_WALL"
  hyprctl hyprpaper wallpaper "$MONITOR,$NEXT_WALL"
done

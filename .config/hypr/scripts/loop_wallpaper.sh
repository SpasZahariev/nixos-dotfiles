#!/usr/bin/env bash

# === Config ===
WIDE_WALLPAPER_DIR="$HOME/dotfiles/wallpapers/wide"
VERTICAL_WALLPAPER_DIR="$HOME/dotfiles/wallpapers/vertical"
CURRENT_WALL=$(hyprctl hyprpaper listloaded)

ALL_MONITORS=(
  "HDMI-A-1"
  "DP-1"
  "DP-2"
)

VERTICAL_MONITORS=(
  "HDMI-A-1"
  "DP-2"
)

# === Defaults ===
DIRECTION=1 # 1 for next, -1 for previous
TARGET_MONITOR=""
VERTICAL_MODE=0

# === Usage ===
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [MONITOR]

Options:
  -p, --previous    Go to previous wallpaper instead of next
  -v, --vertical    Use vertical wallpapers (applies to left and right monitors only)
  -m, --monitor     Specify monitor (HDMI-A-1, DP-1, DP-2)
  -h, --help        Show this help message

Examples:
  $(basename "$0")                  # Next wallpaper on all monitors
  $(basename "$0") -p               # Previous wallpaper on all monitors
  $(basename "$0") -v               # Next vertical wallpaper on left/right monitors
  $(basename "$0") DP-1             # Next wallpaper on DP-1 only
  $(basename "$0") -p -m HDMI-A-1   # Previous wallpaper on HDMI-A-1
EOF
  exit 0
}

# === Argument Parsing ===
while [[ $# -gt 0 ]]; do
  case "$1" in
  -p | --previous)
    DIRECTION=-1
    shift
    ;;
  -v | --vertical)
    VERTICAL_MODE=1
    shift
    ;;
  -m | --monitor)
    TARGET_MONITOR="$2"
    shift 2
    ;;
  -h | --help)
    usage
    ;;
  *)
    # Assume it's a monitor name
    TARGET_MONITOR="$1"
    shift
    ;;
  esac
done

# === Select wallpaper directory ===
if [[ $VERTICAL_MODE -eq 1 ]]; then
  WALLPAPER_DIR="$VERTICAL_WALLPAPER_DIR"
else
  WALLPAPER_DIR="$WIDE_WALLPAPER_DIR"
fi

# === Determine target monitors ===
if [[ -n "$TARGET_MONITOR" ]]; then
  # Validate monitor name
  if [[ ! " ${ALL_MONITORS[*]} " =~ " ${TARGET_MONITOR} " ]]; then
    echo "Error: Invalid monitor '$TARGET_MONITOR'"
    echo "Valid monitors: ${ALL_MONITORS[*]}"
    exit 1
  fi
  MONITORS=("$TARGET_MONITOR")
elif [[ $VERTICAL_MODE -eq 1 ]]; then
  MONITORS=("${VERTICAL_MONITORS[@]}")
else
  MONITORS=("${ALL_MONITORS[@]}")
fi

# === Functions ===

# Get wallpapers sorted by most recently added (newest first)
get_sorted_wallpapers() {
  local dir="$1"
  find "$dir" -type f -printf '%T@ %p\n' | sort -rn | cut -d' ' -f2-
}

# Get the next or previous wallpaper
get_wallpaper() {
  local dir="$1"
  local current_wall="$2"
  local direction="$3"

  # Get all wallpapers sorted by most recently added
  local wallpapers
  mapfile -t wallpapers < <(get_sorted_wallpapers "$dir")

  local count=${#wallpapers[@]}

  if [[ $count -eq 0 ]]; then
    echo "Error: No wallpapers found in $dir" >&2
    exit 1
  fi

  local current_index=-1

  # Find current wallpaper index
  for i in "${!wallpapers[@]}"; do
    if [[ "${wallpapers[$i]}" == "$current_wall" ]]; then
      current_index=$i
      break
    fi
  done

  # Calculate next index with wrapping
  local next_index
  if [[ $current_index -eq -1 ]]; then
    next_index=0
  else
    next_index=$(((current_index + direction + count) % count))
  fi

  echo "${wallpapers[$next_index]}"
}

# === Main ===

# Get the next/previous wallpaper
NEXT_WALL=$(get_wallpaper "$WALLPAPER_DIR" "$CURRENT_WALL" "$DIRECTION")

# Unload current wallpapers
hyprctl hyprpaper unload all

# Preload once
hyprctl hyprpaper preload "$NEXT_WALL"

# Apply to target monitors
for MONITOR in "${MONITORS[@]}"; do
  echo "Setting wallpaper for $MONITOR: $NEXT_WALL"
  hyprctl hyprpaper wallpaper "$MONITOR,$NEXT_WALL"
done

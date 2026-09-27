#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# Wofi cannot expose hover events. Use fzf inside a styled Ghostty window when
# available so the clipboard picker can provide a live, scrollable preview.
if command -v ghostty >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    exec ghostty \
        --class=com.spas.clipboard-picker \
        --title='Clipboard History' \
        --window-decoration=none \
        --background='#24273a' \
        --foreground='#cad3f5' \
        --cursor-color='#c6a0f6' \
        --selection-background='#c6a0f6' \
        --selection-foreground='#24273a' \
        --font-family='JetBrainsMono Nerd Font' \
        --font-size=15 \
        --window-padding-x=14 \
        --window-padding-y=14 \
        -e "$HOME/.config/hypr/scripts/clipboard-picker.sh"
fi

# Fallback for systems without Ghostty or fzf.
selection="$({
    cliphist list
} | wofi --dmenu \
    --prompt "Clipboard" \
    --matching fuzzy \
    --insensitive \
    --no-custom-entry \
    --sort-order default \
    --cache-file /dev/null \
    --hide-scroll \
    --allow-images \
    --parse-search \
    --width 760 \
    --height 620
)" || exit 0

[[ -n "$selection" ]] || exit 0

printf '%s\n' "$selection" | cliphist decode | wl-copy

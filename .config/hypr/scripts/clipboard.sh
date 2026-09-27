#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

paste_file=""
cleanup() {
    if [[ -n "$paste_file" ]]; then
        rm -f "$paste_file" "$paste_file.sel"
    fi
}
trap cleanup EXIT

# Type decoded clipboard bytes at the current cursor via the Wayland
# virtual-keyboard protocol. Images/binary and very large blobs are left
# in the clipboard only (typing them would spew garbage or freeze).
type_at_cursor() {
    local body="$1" marker="${2:-}"
    [[ -s "$body" ]] || return 0
    if [[ -n "$marker" ]] && printf '%s' "$marker" | grep -qF '[[ binary data'; then
        return 0
    fi
    local size
    size=$(wc -c < "$body")
    size=${size//[[:space:]]/}
    if (( size > 20000 )); then
        return 0
    fi
    command -v wtype >/dev/null 2>&1 || return 0
    # Picker window just closed; give Hyprland a beat to refocus the
    # window under the cursor before keystrokes go out.
    sleep 0.3
    wtype - < "$body" || true
}

# Wofi cannot expose hover events. Use fzf inside a styled Ghostty window when
# available so the clipboard picker can provide a live, scrollable preview.
# The picker writes decoded bytes to $CLIPBOARD_PASTE_FILE and exits; typing
# happens here, after Ghostty has closed and focus is back on the target.
if command -v ghostty >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    paste_file=$(mktemp)
    export CLIPBOARD_PASTE_FILE="$paste_file"
    ghostty \
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
        -e "$HOME/.config/hypr/scripts/clipboard-picker.sh" || true
    marker=""
    if [[ -f "$paste_file.sel" ]]; then
        marker=$(cat "$paste_file.sel" || true)
    fi
    type_at_cursor "$paste_file" "$marker"
    exit 0
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

paste_file=$(mktemp)
printf '%s\n' "$selection" | cliphist decode > "$paste_file"
wl-copy < "$paste_file"
type_at_cursor "$paste_file" "$selection"

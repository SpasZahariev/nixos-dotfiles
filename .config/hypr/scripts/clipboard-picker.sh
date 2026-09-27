#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

clear_image_preview() {
    "$HOME/.config/hypr/scripts/clipboard-clear-image.sh"
}
trap clear_image_preview EXIT

# A missing db (fresh install, nothing copied yet) makes cliphist fail;
# treat that the same as an empty history.
history=$(cliphist list 2>/dev/null || true)
empty_message='No matches. Ctrl+R clears search.'
if [[ -z "$history" ]]; then
    empty_message='History is empty. Copy something, then reopen.'
fi

selection="$(
    printf '%s' "$history" |
        env -u FZF_DEFAULT_OPTS -u FZF_DEFAULT_OPTS_FILE fzf \
            --height=100% \
            --ansi \
            --layout=reverse \
            --border=rounded \
            --border-label=' Clipboard history ' \
            --border-label-pos=2 \
            --padding=0,1 \
            --input-border=bottom \
            --list-border=none \
            --preview="$HOME"/.config/hypr/scripts/clipboard-preview.sh' {}' \
            --preview-window='right:50%,border-rounded,wrap,<50(down:45%,border-rounded)' \
            --preview-label=' Full content ' \
            --preview-label-pos=2 \
            --delimiter=$'\t' \
            --nth=2.. \
            --tiebreak=index \
            --no-multi \
            --scrollbar='│' \
            --scroll-off=2 \
            --prompt='Search > ' \
            --ghost='Filter history...' \
            --info=inline-right \
            --header='' \
            --footer=$'Enter copy   Esc close   Ctrl+R reset\nCtrl+/ preview   Ctrl+U/D scroll' \
            --footer-border=top \
            --gutter=' ' \
            --pointer='▸' \
            --marker=' ' \
            --color='fg:#cad3f5,bg:#24273a,fg+:#f4dbd6,bg+:#363a4f,hl:#8bd5ca,hl+:#8bd5ca,info:#a5adcb,prompt:#c6a0f6,gutter:#24273a,pointer:#c6a0f6,marker:#c6a0f6,scrollbar:#6e738d,preview-scrollbar:#6e738d,spinner:#c6a0f6,header:#eed49f,footer:#a5adcb,border:#494d64,label:#c6a0f6,preview-fg:#cad3f5,preview-bg:#1e2030' \
            --bind="zero:change-header($empty_message),one:change-header(),ctrl-r:clear-query" \
            --bind="ctrl-/:execute-silent(\"$HOME/.config/hypr/scripts/clipboard-clear-image.sh\")+toggle-preview" \
            --bind='ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down' \
            --bind='ctrl-up:preview-up,ctrl-down:preview-down,pgup:preview-page-up,pgdn:preview-page-down' \
            --bind='preview-scroll-up:preview-up,preview-scroll-down:preview-down'
)" || exit 0

[[ -n "$selection" ]] || exit 0

# fzf strips ANSI output, but remove it defensively before decoding.
selection=$(printf '%s\n' "$selection" | sed $'s/\033\\[[0-9;]*m//g')
printf '%s\n' "$selection" | cliphist decode | wl-copy

#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

line=${1:-}
[[ -n "$line" ]] || exit 0
line=$(printf '%s\n' "$line" | sed $'s/\033\\[[0-9;]*m//g')

preview_width=${FZF_PREVIEW_COLUMNS:-72}
preview_height=${FZF_PREVIEW_LINES:-24}
[[ "$preview_width" =~ ^[0-9]+$ ]] || preview_width=72
[[ "$preview_height" =~ ^[0-9]+$ ]] || preview_height=24
if (( preview_width > 4 )); then
    preview_width=$((preview_width - 4))
fi
if (( preview_height > 4 )); then
    preview_height=$((preview_height - 4))
fi

# Clear any image left by the previous preview before rendering the next one.
printf '\033_Ga=d,d=A,q=2\033\\'

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT
printf '%s\n' "$line" | cliphist decode > "$tmpfile"

description=${line#*$'\t'}

if [[ "$line" == *$'\t[[ binary data '* ]]; then
    printf '%s\n\n' "$description"

    # Ghostty supports the Kitty graphics protocol. Render image clipboard
    # entries directly in the fzf preview pane, with a text fallback above.
    encoded=$(base64 -w0 "$tmpfile")
    first_chunk=1
    while [[ -n "$encoded" ]]; do
        chunk=${encoded:0:4096}
        encoded=${encoded:4096}
        if [[ -n "$encoded" ]]; then
            printf '\033_Ga=T,f=100,q=2,m=1,c=%s,r=%s;%s\033\\' "$preview_width" "$preview_height" "$chunk"
        elif (( first_chunk )); then
            printf '\033_Ga=T,f=100,q=2,m=0,c=%s,r=%s;%s\033\\' "$preview_width" "$preview_height" "$chunk"
        else
            printf '\033_Ga=T,f=100,q=2,m=0;%s\033\\' "$chunk"
        fi
        first_chunk=0
    done
    exit 0
fi

detect_language() {
    local file="$1"

    if jq -e . "$file" >/dev/null 2>&1; then
        printf '%s' json
    elif rg -q '#!.*(bash|zsh|fish|sh)([^[:alnum:]_]|$)|^[[:space:]]*(set -[eE]|case .* in|function |if \[\[|fi$)' "$file"; then
        printf '%s' bash
    elif rg -q '(^|^[[:space:]])(def |class |from .+ import |import )[[:alnum:]_.]+|if __name__|print\(' "$file"; then
        printf '%s' python
    elif rg -q '(^|^[[:space:]])(const|let|var|function|interface|type) |=>|console\.' "$file"; then
        printf '%s' javascript
    elif rg -q '(^|^[[:space:]])(fn |struct |enum |impl |trait |use std::|let mut )' "$file"; then
        printf '%s' rust
    elif rg -q '(^|^[[:space:]])package [[:alnum:]_]+|func [[:alnum:]_]+\(' "$file"; then
        printf '%s' go
    elif rg -qi '(^|[[:space:]])(select|insert into|update|delete from|create table|alter table)[[:space:]]' "$file"; then
        printf '%s' sql
    elif rg -q '<(!DOCTYPE|html|body|div|svg|[A-Za-z]+[[:space:]][^>]+>)' "$file"; then
        printf '%s' html
    elif rg -q '^[^#/][^{]+\{[^}]*(:|;)' "$file"; then
        printf '%s' css
    elif rg -q '^(#{1,6} |```|[-*+] )' "$file"; then
        printf '%s' markdown
    elif rg -q '(^|[[:space:]])(let|with pkgs|inherit |mkIf|mkOption)[[:space:]]|^[[:space:]]*[{][[:space:]]*(config|pkgs)' "$file"; then
        printf '%s' nix
    elif rg -q '^[[:space:]]*[A-Za-z0-9_.-]+:[[:space:]]' "$file"; then
        printf '%s' yaml
    elif rg -q '^\[[^]]+\]$|^[A-Za-z0-9_.-]+[[:space:]]*=' "$file"; then
        printf '%s' toml
    fi
}

if command -v bat >/dev/null 2>&1; then
    language=$(detect_language "$tmpfile" || true)
    bat_args=(
        --style=plain
        --paging=never
        --color=always
        --wrap=character
        --terminal-width="$preview_width"
    )
    if [[ -n "$language" ]]; then
        bat_args+=(--language="$language")
    else
        bat_args+=(--file-name=clipboard.txt)
    fi
    bat "${bat_args[@]}" "$tmpfile"
else
    cat "$tmpfile"
fi

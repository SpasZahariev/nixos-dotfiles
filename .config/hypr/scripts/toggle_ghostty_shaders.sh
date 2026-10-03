#!/usr/bin/env bash
set -euo pipefail

config="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"

if rg -q '^[[:space:]]*custom-shader[[:space:]]*=' "$config"; then
    sed -i 's/^\([[:space:]]*custom-shader[[:space:]]*=.*\)$/# shader-toggle: \1/' "$config"
elif rg -q '^# shader-toggle: ' "$config"; then
    sed -i 's/^# shader-toggle: //' "$config"
else
    printf 'No custom shaders configured in %s\n' "$config" >&2
    exit 1
fi

busctl --user call com.mitchellh.ghostty /com/mitchellh/ghostty \
    org.gtk.Actions Activate 'sava{sv}' reload-config 0 0

#!/usr/bin/env bash

# Toggle between Navi 31 (58) and Razer Barracuda X (59)
current=$(wpctl status | grep -A10 'Sinks:' | head -8 | grep '\*' | grep -oP '^\s*[│\s]*\*?\s+\K[0-9]+')

if [[ "$current" == "58" ]]; then
  wpctl set-default 59
else
  wpctl set-default 58
fi

#!/usr/bin/env bash
# Remove Kitty graphics from the active Ghostty screen.
printf '\033_Ga=d,d=A,q=2\033\\' > /dev/tty 2>/dev/null || true

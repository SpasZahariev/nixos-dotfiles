#!/usr/bin/env bash
# cycle_spotify.sh - Focus-switcher/cycler for Spotify.
# Thin wrapper around cycle_window.sh; see that file for the shared logic.
set -euo pipefail
exec "$(dirname "$0")/cycle_window.sh" spotify /home/spas/.config/hypr/scripts/spotify.sh

#!/usr/bin/env bash
# cycle_steam.sh - Focus-switcher/cycler for Steam.
# Thin wrapper around cycle_window.sh; see that file for the shared logic.
set -euo pipefail
exec "$(dirname "$0")/cycle_window.sh" steam /home/spas/.config/hypr/scripts/steam.sh

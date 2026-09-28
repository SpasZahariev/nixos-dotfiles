#!/usr/bin/env bash
# cycle_ghostty.sh - Focus-switcher/cycler for Ghostty terminals (SUPER+T).
# Thin wrapper around cycle_window.sh; see that file for the shared logic.
set -euo pipefail
exec "$(dirname "$0")/cycle_window.sh" ghostty ghostty

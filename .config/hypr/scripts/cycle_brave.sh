#!/usr/bin/env bash
# cycle_brave.sh - Focus-switcher/cycler for Brave browser (SUPER+B).
# Thin wrapper around cycle_window.sh; see that file for the shared logic.
set -euo pipefail
exec "$(dirname "$0")/cycle_window.sh" brave-browser brave

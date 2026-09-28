#!/usr/bin/env bash
# cycle_discord.sh - Focus-switcher/cycler for Discord.
# Thin wrapper around cycle_window.sh; see that file for the shared logic.
set -euo pipefail
exec "$(dirname "$0")/cycle_window.sh" discord Discord

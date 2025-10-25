#!/usr/bin/env bash

# Check if gammastep is running
if pgrep -x "gammastep" >/dev/null; then
  echo "Gammastep is running — stopping it..."
  pkill -x gammastep
else
  echo "Gammastep is not running — starting it for Zurich..."
  setsid gammastep -l 47.3769:8.5417 -t 5500:3500 &
fi

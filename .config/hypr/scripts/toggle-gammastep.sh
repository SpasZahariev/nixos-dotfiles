#!/usr/bin/env bash

# Check if gammastep is running
count=$(ps | rg gammastep | wc -l)
if [ "$count" -gt 0 ]; then
  echo "Gammastep is running — stopping it..."
  pkill gammastep
else
  echo "Gammastep is not running — starting it for Zurich..."
  setsid gammastep -m wayland -l 47.3769:8.5417 -t 5500:3500 &
fi

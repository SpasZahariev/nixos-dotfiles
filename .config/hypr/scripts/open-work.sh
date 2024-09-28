#!/bin/bash

# Command to create or attach to the 'work' tmux session and start Vim
tmux_command="tmux new-session -A -s work -c ~ 'nvim .'"

# Open Alacritty and execute the tmux command
alacritty -e bash -c "$tmux_command"

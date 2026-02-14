#!/usr/bin/env bash

## Copyright (C) 2020-2023 Aditya Shakya <adi1090x@gmail.com>
##
## Autostart Programs
## Edited for Garuda Linux by yurihikari

# Kill already running process
_ps=(waybar)
for _prs in "${_ps[@]}"; do
	if [[ `pidof ${_prs}` ]]; then
		killall -9 ${_prs}
	fi
done

# Start gnome keyring
# exec gnome-keyring-daemon --daemonize --start --components=gpg,pkcs11,secrets,ssh &

# Polkit agent
# if [[ ! `pidof xfce-polkit` ]]; then
# 	/usr/lib/xfce-polkit/xfce-polkit &
# fi
# exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# wireplumber &
# pipewire &
# Set wallpaper
# swaybg --output '*' --mode fill --image ~/.config/backgrounds/march7.jpg &
# swww-daemon &

# Apply themes
# ~/.config/hypr/scripts/gtkthemes &

# Lauch statusbar (waybar) Disable if using AGS
~/.config/hypr/scripts/statusbar.sh &

# Start network manager applet
# nm-applet --indicator &

# Start tuxedo-control-center Let it commented if not using Tuxedo
#tuxedo-control-center --tray &

# Start mpd
# exec mpd &

# Start AGS Enable if not using Waybar
# For v1
#exec agsv1 &
# For v2
#exec hyprpanel &

# did't work
# exec $HOME/.config/hypr/scripts/set_wallpaper_all.sh $HOME/wallpapers/wide/ford-gt-3440x1440.png

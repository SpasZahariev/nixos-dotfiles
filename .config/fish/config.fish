## Set values
# Hide welcome message
# set -g fish_greeting ""
# print a nice picture
neofetch
set VIRTUAL_ENV_DISABLE_PROMPT "0"
# set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx MANPAGER most 


## Export variable need for qt-theme
if type "qtile" >> /dev/null 2>&1
   set -x QT_QPA_PLATFORMTHEME "qt5ct"
end

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low


## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
  source ~/.fish_profile
end

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

# Add depot_tools to PATH
if test -d ~/Applications/depot_tools
    if not contains -- ~/Applications/depot_tools $PATH
        set -p PATH ~/Applications/depot_tools
    end
end

# Add ~/.cargo/bin to PATH
if test -d ~/.cargo/bin
    if not contains -- ~/.cargo/bin $PATH
        set -p PATH ~/.cargo/bin
    end
end

# Add ~/.spicetify to PATH
if test -d ~/.spicetify
    if not contains -- ~/.spicetify $PATH
        set -p PATH ~/.spicetify
    end
end

# Add ~/go/bin/ to PATH
if test -d ~/go/bin
    if not contains -- ~/go/bin $PATH
        set -p PATH ~/go/bin
    end
end

## Starship prompt
# if status --is-interactive
#    source (/usr/bin/starship init fish --print-full-init | psub)
# end


## Advanced command-not-found hook
#source /usr/share/doc/find-the-command/ftc.fish


## Functions
# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
	set from (echo $argv[1] | trim-right /)
	set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

## Useful aliases
# Replace ls with eza
alias ls='eza -al --color=always --group-directories-first --icons' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons'  # long format
alias lt='eza -aT --color=always --group-directories-first --icons' # tree listing
alias l.='eza -ald --color=always --group-directories-first --icons .*' # show only dotfiles
alias ip='ip -color'

# Replace some more things with better alternatives
alias cat='bat --style header --style snip --style changes --style header'
[ ! -x /usr/bin/yay ] && [ -x /usr/bin/paru ] && alias yay='paru'

# Replace less with paging syntax highlighted bat
alias less='bat --paging=always'

# Replace find with fd
alias find='fd'

# Replace vim with neovim!
alias vim='nvim'

# Replace cd with Zoxide
# alias cd='z'

# Spotify launcher is too long
alias spot="spotify-launcher"

# useful search and open vim
alias fzfvim="fzf | xargs nvim"

### tmux ###

# attach to a session or create a new one
alias ts='tmux new -ADs'

# tmux kill the last session I was on
alias tk='tmux kill-session -t'

# Common use
alias grubup="sudo update-grub"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias tarnow='tar -acf '
alias untar='tar -xvf '
alias wget='wget -c '
alias rmpkg="sudo pacman -Rdd"
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias upd='/usr/bin/garuda-update'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='grep -F --color=auto'
alias egrep='grep -E --color=auto'
alias hw='hwinfo --short'                          # Hardware Info
alias big="expac -H M '%m\t%n' | sort -h | nl"     # Sort installed packages according to size in MB
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l' # List amount of -git packages

# Get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Help people new to Arch
alias apt='man pacman'
alias apt-get='man pacman'
alias please='sudo'
alias tb='nc termbin.com 9999'

# Cleanup orphaned packages
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# Setup cli apps

set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
--color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 \
--color=selected-bg:#494d64 \
--multi"

fzf --fish | source


# I love this one. Better cd
zoxide init fish | source

# I'll go back to fzf to try it
# better ctrl+r search history
#atuin init fish | source

eval "$(thefuck --alias)"
# You can use whatever you want as an alias like for Mondays:
# eval $(thefuck --alias FUCK)
# eval $(thefuck --alias fuck)


# make nvim the default editor
export EDITOR=nvim

# when i restart linux it seems xfce4-appearance-settings is reset to the default. this is an attempt to set it to Catppuccin
eval $(gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-macchiato-mauve-standard+default')
eval $(gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark')

## Run fastfetch if session is interactive
# if status --is-interactive && type -q fastfetch
#    fastfetch --load-config neofetch
# end

function fish_greeting
    # if function is called - clears all the startup text
    # clear
end

function fishfetch
    clear
    neofetch
end

function mpd_update
    cd ~/Music
    mpc clear
    mpc ls | mpc add
    mpc update
    mpc listall
    cd - 
end

fish_add_path /home/spas/.spicetify

starship init fish | source

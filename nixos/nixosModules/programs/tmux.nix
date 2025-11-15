{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.sensible
      tmuxPlugins.catppuccin
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.yank
      tmuxPlugins.tmux-thumbs
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
    ];
    # catppuccin = {
    #   enable = true;
    #   extraConfig = ''
    #     # Catppuccin theme
    #     set -g @catppuccin_flavour 'macchiato'
    #     set -g @catppuccin_window_tabs_enabled on
    #     set -g @catppuccin_date_time "%H:%M"
    #     set -g @catppuccin_window_left_separator ""
    #     set -g @catppuccin_window_right_separator " "
    #     set -g @catppuccin_window_middle_separator " █"
    #     set -g @catppuccin_window_number_position "right"
    #     set -g @catppuccin_window_default_fill "number"
    #     set -g @catppuccin_window_default_text "#W"
    #     set -g @catppuccin_window_current_fill "number"
    #     set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag,(),}"
    #     set -g @catppuccin_status_modules_right "directory" # date_time"
    #     set -g @catppuccin_status_modules_left "session"
    #     set -g @catppuccin_status_left_separator  " "
    #     set -g @catppuccin_status_right_separator " "
    #     set -g @catppuccin_status_right_separator_inverse "no"
    #     set -g @catppuccin_status_fill "icon"
    #     set -g @catppuccin_status_connect_separator "no"
    #     set -g @catppuccin_directory_text "#{b:pane_current_path}"
    #   '';
    # };

    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      # make sure tmux knows to use nushell
      set -g default-command "nu"
      set -g default-shell "/run/current-system/sw/bin/nu"

      # Prefix key
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # Indices
      set -g base-index 1 # window indices start from 1 instead of 0 for easier reach
      set -g renumber-windows on # closing a window will rename the rest to fit
      set -g pane-base-index 1

      # Quality of life
      set -g mouse on
      set-option -g history-limit 5000
      set -g renumber-windows on


      # # load catppuccin files
      # run-shell "~/.tmux/plugins/tmux/catppuccin.tmux"

      # Better splits
      unbind %
      bind "|" split-window -h -c "#{pane_current_path}"
      bind "\\" split-window -fh -c "#{pane_current_path}"
      unbind '"'
      bind "-" split-window -v -c "#{pane_current_path}"
      bind "_" split-window -fv -c "#{pane_current_path}"

      # Window/session switching
      bind Space last-window
      bind-key C-Space switch-client -l

      # make my super cool dev env windows
      bind v split-window -h -p 15 -c "#{pane_current_path}" 'opencode' \; \
       select-pane -L \; \
       split-window -v -p 25 -c "#{pane_current_path}" \; \
       send-keys 'source ~/.config/nushell/top-3-ps.nu' C-m \; \
       select-pane -U \; \
       send-keys 'nvim .' C-m


      # vim-tmux-navigator (move from neovim to other tmux panes)
      set -g @vim_navigator_mapping_left "C-Left C-h"  # use C-h and C-Left
      set -g @vim_navigator_mapping_right "C-Right C-l"
      set -g @vim_navigator_mapping_up "C-k"
      set -g @vim_navigator_mapping_down "C-j"
      set -g @vim_navigator_mapping_prev ""  # removes the C-\ binding

      # Copy mode (vim style)
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind Escape copy-mode

      # Reload config
      # Don't forget to nix-fast rebuild before you reload the config
      # bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
      bind r source-file /etc/tmux.conf \; display-message "Config reloaded!"

      # Paste buffer
      unbind p
      bind p paste-buffer

      # Bind 'l' to open URLs from the current pane
      unbind l
      bind l run-shell -b "tmux capture-pane -J -p | rg -o '(https?://[^\s>]+)' | fzf-tmux -d20 --multi --bind 'alt-a:select-all,alt-d:deselect-all' | xargs -r xdg-open"

      # move areound windows
      bind H previous-window
      bind L next-window

      # Catppuccin theme
      set -g @catppuccin_flavour 'macchiato'
      set -g @catppuccin_window_tabs_enabled on
      set -g @catppuccin_date_time "%H:%M"
      set -g @catppuccin_window_left_separator ""
      set -g @catppuccin_window_right_separator " "
      set -g @catppuccin_window_middle_separator " █"
      set -g @catppuccin_window_number_position "right"
      set -g @catppuccin_window_default_fill "number"
      set -g @catppuccin_window_default_text "#W"
      set -g @catppuccin_window_current_fill "number"
      set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag,(),}"
      set -g @catppuccin_status_modules_right "directory" # date_time"
      set -g @catppuccin_status_modules_left "session"
      set -g @catppuccin_status_left_separator  " "
      set -g @catppuccin_status_right_separator " "
      set -g @catppuccin_status_right_separator_inverse "no"
      set -g @catppuccin_status_fill "icon"
      set -g @catppuccin_status_connect_separator "no"
      set -g @catppuccin_directory_text "#{b:pane_current_path}"

      # Resurrect/Continuum
      set -g @resurrect-strategy-vim 'session'
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-boot 'on'
      set -g @continuum-save-interval '10'
      set -g @continuum-restore 'on'
    '';
  };
}


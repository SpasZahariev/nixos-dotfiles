{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.sensible
      tmuxPlugins.catppuccin
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.yank
      tmuxPlugins.tmux-thumbs
    ];

    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Prefix key
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # Indices
      set -g base-index 1
      set -g pane-base-index 1

      # Quality of life
      set -g mouse on
      set-option -g history-limit 5000
      set -g renumber-windows on

      # Better splits
      unbind %
      bind "|" split-window -h -c "#{pane_current_path}"
      unbind '"'
      bind "-" split-window -v -c "#{pane_current_path}"

      # Window/session switching
      bind Space last-window
      bind-key C-Space switch-client -l

      # Copy mode (vim style)
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind Escape copy-mode

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # Paste buffer
      unbind p
      bind p paste-buffer

      # Catppuccin theme
      set -g @catppuccin_flavour 'frappe'
      set -g @catppuccin_window_tabs_enabled on
      set -g @catppuccin_date_time "%H:%M"

      # Resurrect/Continuum
      set -g @resurrect-strategy-vim 'session'
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'
      set -g @continuum-boot 'on'
      set -g @continuum-save-interval '10'
    '';
  };
}


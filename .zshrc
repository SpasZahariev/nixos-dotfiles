# ==================== Environment and PATH ====================

export SHELL=/run/current-system/sw/bin/zsh
export RUSTFLAGS="-C linker=$HOME/.local/bin/gcc"

[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
[[ -r "$HOME/.config/zsh/secrets.zsh" ]] && source "$HOME/.config/zsh/secrets.zsh"

# Keep NixOS's inherited environment and remove duplicate PATH entries.
typeset -U path PATH
path=("$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/.npm-global/bin" "$HOME/.bun/bin" $path)
eval "$(dircolors -b)"

# ==================== Environment variables ====================

export EDITOR=nvim
export VISUAL=nvim

# ==================== History and shell options ====================

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE INTERACTIVE_COMMENTS
setopt AUTO_LIST AUTO_MENU COMPLETE_IN_WORD

# ==================== Completion and keybindings ====================

autoload -Uz compinit
if (( ! $+functions[compdef] )); then
    compinit
fi
zmodload zsh/complist
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

bindkey -e
bindkey '^I' menu-complete
bindkey '^[[Z' reverse-menu-complete
bindkey -M menuselect '^I' menu-complete
bindkey -M menuselect '^[[Z' reverse-menu-complete
bindkey '^@' menu-complete
bindkey '^R' history-incremental-search-backward
bindkey '^Q' history-incremental-search-backward
bindkey '^Z' undo
bindkey '^[r' redo
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^O' edit-command-line
bindkey '^X^E' edit-command-line

copy-buffer() {
  print -rn -- "$BUFFER" | wl-copy
  zle -M "Copied to clipboard"
}
zle -N copy-buffer
bindkey '^X^Y' copy-buffer
zle_bracketed_paste=($'\e[?2004h' $'\e[?2004l')

# Carapace's generated aliases must not override the personal PATH priority.
typeset _completion_path="$PATH"
eval "$(carapace _carapace zsh)"
PATH="$_completion_path"
unset _completion_path

# ==================== Aliases ====================

alias v='nvim'
alias vim='nvim'
alias h='herdr'
alias cat='bat'
alias r='source "$HOME/.zshrc" && echo ".zshrc reloaded!"'
alias ls='eza --long --icons --group-directories-first'
alias nix-vim='nvim "$HOME/dotfiles/nixos/configuration.nix"'
alias vim-nix='nix-vim'
alias nix-switch='sudo nixos-rebuild switch --flake "$HOME/dotfiles/nixos#nixos" -I "nixos-config=$HOME/dotfiles/nixos/configuration.nix"'
alias nix-fast='sudo nixos-rebuild switch --flake "$HOME/dotfiles/nixos#nixos" -I "nixos-config=$HOME/dotfiles/nixos/configuration.nix" --fast --no-write-lock-file --offline --option eval-cache true'
alias weather='curl "wttr.in/zuerich"'
alias weather2='curl "wttr.in/zuerich?format=v2"'
alias lg='lazygit'
alias sw='"$HOME/dotfiles/.config/hypr/scripts/set_wallpaper_all.sh"'
alias oc='opencode-local'
eval "$(pay-respects zsh --alias fuck --nocnf)"
alias f='fuck'

# Suffix aliases: typing `file.md` opens it directly
alias -s md=nvim
alias -s json=nvim
alias -s png=loupe
alias -s jpg=loupe
alias -s jpeg=loupe
alias -s pdf=brave

# Global aliases: can be typed anywhere in the buffer (not just the start)
# this one is for piping error logs into the nether
alias -g NE='2>/dev/null'


# ==================== Utility functions ====================

# copy recently viewed file into current dir
c() {
    local dir file
    dir=$(command zoxide query --interactive -- "$@") || return
    file=$(
        builtin cd -- "$dir" || exit 1
        command find . \( -type f -o -xtype f \) -print0 |
            command fzf --read0 --print0 --no-multi --height=7 \
                --layout=reverse --prompt='File to copy > ' \
                --header="From: $dir"
    ) || return
    file=${file%$'\0'}
    [[ -n "$file" ]] || return 1
    command cp -iv -- "$dir/$file" .
}

ya() {
    local tmp cwd exit_code=0
    tmp=$(mktemp -t yazi-cwd.XXXXXX) || return
    {
        yazi "$@" --cwd-file "$tmp"
        exit_code=$?
        if [[ -s "$tmp" ]]; then
            cwd=$(<"$tmp")
            [[ -d "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
        fi
    } always {
        command rm -f -- "$tmp"
    }
    return "$exit_code"
}


# ==================== Local AI functions ====================

opencode-local() {
    local started=$SECONDS health
    print 'Starting llama-server...'
    systemctl --user start llama-server.service || return
    print 'Waiting for llama-server to be ready...'
    while (( SECONDS - started < 120 )); do
        if ! systemctl --user is-active --quiet llama-server.service; then
            print -u2 'llama-server stopped before becoming ready. Check journalctl --user -u llama-server.'
            return 1
        fi
        health=$(curl --fail --silent --max-time 2 http://localhost:11434/health)
        if [[ $(print -r -- "$health" | jq -r '.status // empty' 2>/dev/null) == ok ]]; then
            print 'llama-server ready. Launching opencode...'
            opencode "$@"
            return $?
        fi
        sleep 2
    done
    print -u2 'llama-server was not ready within 120 seconds. Check journalctl --user -u llama-server.'
    return 1
}

llama-profiles() {
    local model="$HOME/.cache/huggingface/hub/models--unsloth--Qwen3.8-27B-GGUF/snapshots/f1bfb127c64f7072bdd2cad55f258b9c8b2910fe/Qwen3.8-27B-UD-Q4_K_XL.gguf"
    local mmproj="$HOME/.cache/huggingface/hub/models--unsloth--Qwen3.8-27B-GGUF/snapshots/4ca720788d1e01f1bff70c033e0d0028fd02e502/mmproj-F16.gguf"
    jq -n --arg model "$model" --arg mmproj "$mmproj" --args '
        $ARGS.positional as $common |
        {
            "qwen38-thinking": {
                model: $model, mmproj: $mmproj,
                args: ($common + ["-c", "135000", "--temp", "1.0", "--top_p", "0.95",
                    "--presence_penalty", "0.0"])
            },
            gaming: {
                model: $model, mmproj: $mmproj,
                args: ($common + ["-c", "75000", "--temp", "1.0", "--top_p", "0.95",
                    "--presence_penalty", "0.0"])
            },
            "qwen38-instruct": {
                model: $model, mmproj: $mmproj,
                args: ($common + ["-c", "135000", "--chat-template-kwargs",
                    "{\"enable_thinking\":false}", "--reasoning-budget", "0",
                    "--temp", "0.7", "--top_p", "0.80", "--presence_penalty", "1.5"])
            }
        }
    ' -- --port 11434 --api-key sk-local-token --spec-draft-n-max 4 \
        -ngl 99 -ngld 99 --flash-attn on --cache-type-k q8_0 --cache-type-v q8_0 \
        -t 16 -b 2048 -ub 2048 --load-mode mlock --top_k 20 --min_p 0.0 \
        --repeat_penalty 1.0
}

llama-start() {
    local profile="${1-}" profiles cfg model mmproj
    local -a args
    profiles=$(llama-profiles) || return
    if (( $# != 1 )) || ! cfg=$(print -r -- "$profiles" | jq -e --arg profile "$profile" '.[$profile]'); then
        print -u2 "Unknown profile: $profile. Options: qwen38-thinking, gaming, qwen38-instruct"
        return 1
    fi
    model=$(print -r -- "$cfg" | jq -r '.model') || return
    mmproj=$(print -r -- "$cfg" | jq -r '.mmproj') || return
    args=("${(@f)$(print -r -- "$cfg" | jq -r '.args[]')}")
    if [[ ! -r "$model" || ! -r "$mmproj" ]]; then
        print -u2 'Model or projector file is missing or unreadable. Run llama-profiles to check paths.'
        return 1
    fi
    llama-stop || return
    systemd-run --user --unit=llama-server --collect -p LimitMEMLOCK=infinity -- \
        llama-server -m "$model" "${args[@]}" --mmproj "$mmproj" || return
    print "Started $profile. Logs: journalctl --user -u llama-server -f"
}

llama-stop() {
    # An absent transient unit is already stopped. Do not hide other failures.
    local load_state
    load_state=$(systemctl --user show llama-server.service --property=LoadState --value) || return
    [[ "$load_state" == not-found ]] && return 0
    systemctl --user stop llama-server.service
}

# ==================== Prompt and shell integrations ====================

eval "$(starship init zsh)"

# Transient prompt: keep full prompt on active line, collapse previous lines to $character.
# Starship has no built-in zsh `enable_transience`, so emulate via zle-line-finish.
autoload -Uz add-zle-hook-widget
TRANSIENT_PROMPT="${PROMPT// prompt / prompt --profile transient }"
TRANSIENT_RPROMPT=""
transient-prompt() {
  PROMPT="$TRANSIENT_PROMPT" RPROMPT="$TRANSIENT_RPROMPT" zle .reset-prompt 2>/dev/null
}
add-zle-hook-widget zle-line-finish transient-prompt
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"

if (( $+commands[atuin] )); then
    eval "$(atuin init zsh --disable-up-arrow)"
    bindkey '^Q' atuin-search
fi

# ==================== Startup display ====================

if (( COLUMNS >= 90 && LINES >= 24 )); then
    fastfetch
fi

# ==================== Autosuggestions and syntax highlighting ====================

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
source /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=green'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=green'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
source /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

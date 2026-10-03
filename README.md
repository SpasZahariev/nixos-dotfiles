## Rice ready for the next time my machine melts down and I have to setup everything from scratch

![Snippet On 18/11/2025](/wallpapers/repo-image.png)
![Snippet On 18/11/2025](/wallpapers/repo-image2.png)
![Snippet On 18/11/2025](/wallpapers/repo-image3.png)

## Shell setup

Zsh's personal configuration lives in `.zshrc`, with aliases, environment,
completion, functions, prompt, and plugins in separate sections.

```sh
ln -s "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
sudo nixos-rebuild switch --flake "$HOME/dotfiles/nixos#nixos" --no-write-lock-file
```

NixOS owns desktop/session environment variables and installs zsh and its plugins.
`.zshrc` owns interactive configuration; no personal `.zprofile` or `.zshenv` is
needed. Put local credentials in `~/.config/zsh/secrets.zsh` with mode `0600`,
not in this repository. History is stored in `~/.zsh_history`.

Atuin records searchable history locally in addition to zsh's history file.
Ctrl+R or Ctrl+Q opens its compact, 10-line inline search; Up keeps normal shell
history navigation. Preview and help panels are hidden.

After rebuilding, link the configuration and import existing history once:

```sh
ln -s "$HOME/dotfiles/.config/atuin" "$HOME/.config/atuin"
source "$HOME/.zshrc"
atuin import zsh
```

Ghostty and herdr explicitly launch zsh so inherited shell settings cannot
select a different shell. Existing panes keep their current shell until closed.

`t` launches or attaches to Herdr. `tk` stops the current Herdr server and all
its panes. Fastfetch is suppressed inside Herdr. In Neovim, Ctrl+H/J/K/L moves
between editor splits first, then neighboring Herdr panes at the editor's edge.

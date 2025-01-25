# dotfiles

My personal dotfiles, managed by [chezmoi](https://github.com/twpayne/chezmoi).

## chezmoi quick reference

chezmoi saves state in `~/.local/share/chezmoi` on all platforms.

command syntax:

```shell
chezmoi cd
chezmoi init
chezmoi add ~/AppData/Local/nvim
chezmoi edit ~/.config/nvim/init.vim
chezmoi diff
chezmoi -v apply
```


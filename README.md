# dotfiles

My personal dotfiles, managed by [chezmoi](https://github.com/twpayne/chezmoi)
for Windows interoperability.

## Notable

This collection of dotfiles aims to provide a consistent tiling window manager
and terminal experience across all platforms. We also leverage the [WezTerm](https://wezterm.com/)
terminal emulator along with the [NeoVim](https://neovim.io/) text editor to
provide a consistent developer experience.

## Software Requirements

### All Platforms

- chezmoi (dotfiles manager)
- git (version control)
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation) (fast grep)
- [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip) (font)

### MacOS

- brew (package manager)
- aerospace (window manager)
- aeroplace (window manager extension)

### Windows

- winget (package manager)
- Komorebi (window manager)
- Powershell (shell)

### Linux

- Hyprland (window manager)
- tbd

## Extra Configuration Requirements

### Windows
To autostart tiling windows on boot, you will want to create a shortcut in
`shell:startup` that points to `"C:\Program Files\komorebi\bin\komorebic.exe" start --bar --whkd`

## Chezmoi Quick Reference

Clone this repository to `~/.local/share/chezmoi` on all platforms. Apply
dotfiles after clone with:

```shell
chezmoi -v apply
```


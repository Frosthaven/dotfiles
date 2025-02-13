# dotfiles

My personal dotfiles, managed by [Chezmoi](https://github.com/twpayne/chezmoi)
for cross-platform interoperability.

## Notable

This collection of dotfiles aims to provide a consistent tiling window manager
and terminal experience across all platforms. You can review the [package.yaml](.chezmoidata/package.yaml) file for a list of all packages that are installed on each platform.

## Software Requirements

### All Platforms

- Chezmoi
- [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip)

### MacOS

- brew (package manager)

### Windows

- winget (package manager)
- Powershell (shell)

### Linux

- tbd

## Extra Configuration Requirements

### Windows
To autostart tiling windows on boot, you will want to create a shortcut in
`shell:startup` that points to `"C:\Program Files\komorebi\bin\komorebic.exe" start --bar --whkd`

## Chezmoi Quick Reference

Clone this repository to `~/.local/share/chezmoi` on all platforms. Apply
dotfiles and package installation with:

```shell
chezmoi -v apply
```


# Frosthaven's dotfiles

My personal dotfiles, managed by [chezmoi](https://github.com/twpayne/chezmoi).

This collection of personal dotfiles attempts to provide a consistant tiling window manager and developer experience on all patforms. It does this by favoring cross-platform packages where possible.

You can review [package.yaml](.chezmoidata/packages.yaml) for a list of all packages, or browse the [dot_config](dot_config) folder for the raw dots.

## Software Requirements

- Package Manager (Windows: [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget), MacOS: [homebrew](https://brew.sh/), Linux: tbd)
- [chezmoi](https://www.chezmoi.io/install/)
- [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip)

## Deploying These Dotfiles

1. Install the listed software requirements for your platform.
2. Clone this repository to `~/.local/share/chezmoi`.
3. Run `chezmoi -v apply`.
4. View the [shell_profiles](./shell_profiles) folder for integrating into your
   shell of choice. This step is generally only needed for the initial setup.

## Extra Configuration Notes

### Komorebic (Windows)
To autostart tiling windows on boot, you will want to create a shortcut in
`shell:startup` that points to `"C:\Program Files\komorebi\bin\komorebic.exe" start --bar --whkd`

### Todo

- [ ] Add MacOS shell profile management
- [ ] Add Linux

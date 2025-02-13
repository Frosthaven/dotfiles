# Frosthaven's dotfiles

My personal dotfiles, managed by [chezmoi](https://github.com/twpayne/chezmoi).

This collection of personal dotfiles attempts to provide a consistant tiling window manager and developer experience on all patforms. It does this by favoring cross-platform packages where possible.

You can review [package.yaml](.chezmoidata/packages.yaml) for a list of all packages, or browse the [dot_config](dot_config) folder for the raw dots.

## Software Requirements

- Package Manager (Windows: [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget), MacOS: [homebrew](https://brew.sh/), Linux: tbd)
- [chezmoi](https://www.chezmoi.io/install/)
- [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip)

## Deployment

1. Install the listed software requirements for your platform.
2. Clone this repository to `~/.local/share/chezmoi`.
3. Run `chezmoi -v apply`.
4. Add shell integrations from the next section.

## Shell Integration

<details>
<summary>Powershell</summary>

Add the following line to `$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`:

```powershell
. $env:USERPROFILE\.config\shell\chezmoi-powershell.ps1
```
</details>

<details>
<summary>ZSH</summary>

Add the following line to `$HOME/.zshrc`:

```sh
source $HOME/.config/shell/chezmoi-zsh.sh
```
</details>

## Optional Configuration

<details>
<summary>Windows: Automatically start tiling window manager</summary>
    
create a shortcut in `shell:startup` with a value of `komorebic.exe start --bar --whkd`
</details>

### Todo

- [ ] Add Linux

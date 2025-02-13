# Frosthaven's dotfiles (managed by [chezmoi](https://github.com/twpayne/chezmoi))

This collection of personal dotfiles attempts to provide a consistant tiling window manager and developer experience on all patforms. It does this by favoring cross-platform packages where possible.

## Deployment

1. Install software requirements
    <details open>
    <summary>Package Manager</summary>
        
    - Windows: [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget)
    - MacOS: [homebrew](https://brew.sh/)
    - Linux: tbd
    </details>
    
    <details open>
    <summary>chezmoi</summary>

    - Follow the [installing guide](https://www.chezmoi.io/install/)
    </details>

    <details open>
    <summary>JetBrainsMono Nerd Font</summary>

    - [Download](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip) and install the font.
    </details>

3. Clone this repository into `~/.local/share/chezmoi`.
4. Run `chezmoi -v apply`.
5. Add shell integrations:
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
6. Apply optional configurations:
    <details>
    <summary>Windows - Automatically start tiling window manager</summary>
        
    create a shortcut in `shell:startup` with a value of `komorebic.exe start --bar --whkd`
    </details>

### Todo

- [ ] Add Linux

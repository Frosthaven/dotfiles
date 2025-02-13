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
5. Manual shell integration:
    <summary>ZSH</summary>

    Add the following line to `$HOME/.zshrc`:

    ```sh
    source $HOME/.config/shell/chezmoi-zsh.sh
    ```
    </details>
6. Apply optional configurations:
    <details>
    <summary>Windows - Automatically start tiling window manager</summary>

    - create a shortcut in `shell:startup` with a value of `komorebic.exe start --bar --whkd`
    </details>

    <details>
    <summary>Windows - Fix Wezterm Transparency on Nvidia GPUs</summary>

    - Open NVIDIA Control Panel
    - Go to `Manage 3D Settings`
    - Click the `Program Settings` tab
    - Add wezterm if it isn't already in the list
    - Change `OpenGL GDI Compatibility` to `Prefer compatible`
    - Click Apply
    </details>

### Todo

- [ ] Add Linux

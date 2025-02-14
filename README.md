# Frosthaven's dotfiles (managed by [chezmoi](https://github.com/twpayne/chezmoi))

This collection of personal dotfiles attempts to provide a consistant tiling window manager and developer experience on all patforms. It does this by favoring cross-platform packages where possible.

## Deployment

1. Clone this repository into `~/.local/share/chezmoi`.
2. Run `chezmoi -v apply`.
3. Apply optional configurations:
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


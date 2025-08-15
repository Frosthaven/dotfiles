# Frosthaven's dotfiles (managed by [chezmoi](https://github.com/twpayne/chezmoi))

This collection of personal dotfiles attempts to provide a consistant tiling window manager and developer experience on all patforms. It does this by favoring cross-platform packages where possible.

## Preparation

### Windows

1. Enable WSL

2. Configure repository access as needed.

3. Install chocolatey & set execution user script execution policy + symlink creation policy (admin shell):

```ps1
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d 1;
```

4. Run installation (non-admin shell):

```ps1
mkdir ~/.local/share/chezmoi; winget install Microsoft.DotNet.DesktopRuntime.8; winget install --id Git.Git -e --source winget; winget install twpayne.chezmoi;
```

5. Restart the PC

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

    <details>
    <summary>Windows - Autohide the cursor</summary>

    - Download & save [AutoHideMouseCursor](https://www.majorgeeks.com/files/details/autohidemousecursor.html) somewhere safe
    - Run the downloaded exe
    - Enable `Strat with Windows`
    - Enable `Hide when a key is pressed`
    - Set the timer range to `3 seconds`
    - Set the strategy to aggressive via `# Options` > `Hide Mouse` > `New Strategy + Aggressive`
    </details>

    <details>
    <summary>MacOS - Autohide the cursor</summary>

    - Access `cursorcerer` from the settings panel or spotlight search
    - Set the automatic timeout to below 5 seconds
    </details>

    <details>
    <summary>MacOS - Disable Conflicting Hotkeys</summary>

    - Open `System Settings` -> `Keyboard` -> `Keyboard Shortcuts` -> `Mission Control`
    - Disable or change all entries that use `ctrl + arrow` keys
    </details>

### Todo

- [ ] Add Linux


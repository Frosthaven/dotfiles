# Frosthaven's dotfiles (managed by [chezmoi](https://github.com/twpayne/chezmoi))

This collection of personal dotfiles attempts to provide a consistant tiling window manager and developer experience on all patforms. It does this by favoring cross-platform packages where possible.

## Automatic Deployment

<details>

<summary>Windows</summary>

Run the following in an Administrator Powershell terminal and reboot the machine afterward:

```ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Wait until choco is available
$maxRetries = 20
$retryCount = 0
while (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Start-Sleep -Seconds 2
    $retryCount++
    if ($retryCount -ge $maxRetries) {
        Write-Error "choco not found after waiting. Exiting."
        exit 1
    }
}

# Install packages
choco install git chezmoi -y

# Set execution policy again and enable developer mode
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d 1

# Run chezmoi init as non-admin
Start-Process powershell -ArgumentList 'chezmoi init https://github.com/Frosthaven/dotfiles' -WorkingDirectory $env:USERPROFILE

# Install Rust Toolchain with GCC
if (-not (Get-Command rustc -ErrorAction SilentlyContinue)) { Invoke-WebRequest https://win.rustup.rs/x86_64 -OutFile rustup-init.exe; Start-Process rustup-init.exe -ArgumentList "-y" -Wait; Remove-Item rustup-init.exe; winget install --id MSYS2.MSYS2 -e --silent; $msys2="$Env:ProgramFiles\MSYS2\msys2.exe"; Start-Process $msys2 -ArgumentList "-mingw64","pacman -Syu --noconfirm mingw-w64-x86_64-toolchain base-devel" -Wait }

chezmoi update
```

</details>

## Manual Deployment

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
    - Enable `Start with Windows`
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





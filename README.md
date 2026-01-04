# Frosthaven's dotfiles (managed by [chezmoi](https://github.com/twpayne/chezmoi))

A cross-platform dotfiles setup providing a consistent tiling window manager and developer experience on Arch Linux, macOS, and Windows. Favors cross-platform packages where possible.

## Setup

1. Install [chezmoi](https://www.chezmoi.io/install/)
2. Run:
   ```bash
   chezmoi init https://github.com/Frosthaven/dotfiles
   chezmoi apply
   ```
3. When prompted "Are you the GitHub repository owner?", answer `n`

That's it! Identity files (SSH, git, rclone) are skipped - set up your own as needed.

> **Frosthaven?** See [docs/OWNER.md](docs/OWNER.md) for repo owner setup.

## Documentation

- [pass-ssh-unpack](docs/pass-ssh-unpack.md) - Extract SSH keys from Proton Pass to local files
- [Identity Setup](docs/IDENTITY.md) - Configure identity files (SSH, git, rclone)

## Automatic Deployment (Windows)

Run the following in an Administrator PowerShell terminal and reboot afterward:

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

# Install Visual Studio Community With C++ Workload
winget install --id Microsoft.VisualStudio.2022.BuildTools -e --accept-package-agreements --accept-source-agreements --override "--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --includeOptional"

# Install Rust Toolchain with GCC
if (-not (Get-Command rustc -ErrorAction SilentlyContinue)) { Invoke-WebRequest https://win.rustup.rs/x86_64 -OutFile rustup-init.exe; Start-Process -FilePath rustup-init.exe -ArgumentList "-y" -Wait; Remove-Item rustup-init.exe; winget install --id MSYS2.MSYS2 -e --accept-package-agreements --accept-source-agreements; $msysBash="C:\msys64\usr\bin\bash.exe"; if (Test-Path $msysBash) { & $msysBash -lc "pacman -Syu --noconfirm mingw-w64-x86_64-toolchain base-devel"; $mingwBin='C:\msys64\mingw64\bin'; $cargoBin=Join-Path $env:USERPROFILE '.cargo\bin'; if (Test-Path (Join-Path $mingwBin 'gcc.exe')) { $env:Path += ';' + $mingwBin + ';' + $cargoBin; rustup target add x86_64-pc-windows-gnu; rustc --version; rustup component add rust-analyzer } else { Write-Error 'gcc.exe not found in MSYS2 mingw64' } } else { Write-Error 'MSYS2 bash.exe not found' } }

chezmoi update
```

## Platform-Specific Configuration

<details>
<summary>Windows - Automatically start tiling window manager</summary>

Create a shortcut in `shell:startup` with a value of `komorebic.exe start --bar --whkd`

</details>

<details>
<summary>Windows - Fix Wezterm Transparency on Nvidia GPUs</summary>

1. Open NVIDIA Control Panel
2. Go to `Manage 3D Settings`
3. Click the `Program Settings` tab
4. Add wezterm if it isn't already in the list
5. Change `OpenGL GDI Compatibility` to `Prefer compatible`
6. Click Apply

</details>

<details>
<summary>Windows - Autohide the cursor</summary>

1. Download & save [AutoHideMouseCursor](https://www.majorgeeks.com/files/details/autohidemousecursor.html) somewhere safe
2. Run the downloaded exe
3. Enable `Start with Windows`
4. Enable `Hide when a key is pressed`
5. Set the timer range to `3 seconds`
6. Set the strategy to aggressive via `# Options` > `Hide Mouse` > `New Strategy + Aggressive`

</details>

<details>
<summary>macOS - Autohide the cursor</summary>

1. Access `cursorcerer` from the settings panel or spotlight search
2. Set the automatic timeout to below 5 seconds

</details>

<details>
<summary>macOS - Disable Conflicting Hotkeys</summary>

1. Open `System Settings` -> `Keyboard` -> `Keyboard Shortcuts` -> `Mission Control`
2. Disable or change all entries that use `ctrl + arrow` keys

</details>

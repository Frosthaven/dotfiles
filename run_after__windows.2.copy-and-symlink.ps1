# This handles symbolic links, junctions, and copying files, which allows us
# to continue using the same configuration files in the repository.

If ($PSVersionTable.PSVersion.Major -Le 5 -Or $isWindows) {
    Write-Host ""
    Write-Host "Checking for symbolic links and integrations..."

    # Alacritty
    If ((Test-Path $env:APPDATA\Alacritty) -and (Get-Item $env:APPDATA\Alacritty).Attributes -ne "ReparsePoint") {
        Remove-Item $env:APPDATA\Alacritty -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path $env:APPDATA\Alacritty -ItemType Junction -Value $env:USERPROFILE\.config/alacritty | Out-Null
    }

    # Neovim
    If ((Test-Path $env:LOCALAPPDATA\nvim) -and (Get-Item $env:LOCALAPPDATA\nvim).Attributes -ne "ReparsePoint") {
        Remove-Item $env:LOCALAPPDATA\nvim -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path $env:LOCALAPPDATA\nvim -ItemType Junction -Value $env:USERPROFILE\.config/nvim | Out-Null
    }

    # Komorebi

    Write-Host ""
    Write-Host "Updating Komorebi Application Specific Configuration..."
    komorebic fetch-asc
    if (-not [Environment]::GetEnvironmentVariable('KOMOREBI_CONFIG_HOME', 'User')) {
        $value = Join-Path $env:USERPROFILE '.config\komorebi'
        Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile', '-Command', "Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'KOMOREBI_CONFIG_HOME' -Value '$env:USERPROFILE\.config\komorebi'"
        Write-Host "KOMOREBI_CONFIG_HOME was not set, now set to: $value"

        # Refresh environment variable in the current session
        $env:KOMOREBI_CONFIG_HOME = [Environment]::GetEnvironmentVariable('KOMOREBI_CONFIG_HOME', 'User')
    } else {
        $current = [Environment]::GetEnvironmentVariable('KOMOREBI_CONFIG_HOME', 'User')
    }

    # Clink Scripts
    If (-Not (Test-Path $env:LOCALAPPDATA\clink)) {
        New-Item -Path $env:LOCALAPPDATA\clink -ItemType Directory | Out-Null
    }
    Copy-Item -Path $env:USERPROFILE\.config\clink\* -Destination $env:LOCALAPPDATA\clink -Recurse -Force | Out-Null

    # Automatic Shell Integration
    $psProfilePath = Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    If (-Not (Test-Path $psProfilePath)) {
        New-Item -Path $psProfilePath -ItemType File | Out-Null
    }
    If (-Not (Select-String -Path $psProfilePath -Pattern "chezmoi-powershell.ps1")) {
        Add-Content -Path $psProfilePath -Value "# Load Chezmoi PowerShell profile" | Out-Null
        Add-Content -Path $psProfilePath -Value ". '$env:USERPROFILE\.config\shell\powershell\chezmoi-powershell.ps1'" | Out-Null
    }

    # Automatic Zoxide Integration
    If (-Not (Select-String -Path $psProfilePath -Pattern "chezmoi-powershell-zoxide.ps1")) {
        Add-Content -Path $psProfilePath -Value "# Load Zoxide PowerShell profile" | Out-Null
        Add-Content -Path $psProfilePath -Value ". '$env:USERPROFILE\.config\shell\powershell\chezmoi-powershell-zoxide.ps1'" | Out-Null
    }

    # Nushell
    If ((Test-Path $env:APPDATA\nushell) -and (Get-Item $env:APPDATA\nushell).Attributes -ne "ReparsePoint") {
        Remove-Item $env:APPDATA\nushell -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path $env:APPDATA\nushell -ItemType Junction -Value $env:USERPROFILE\.config\shell\nushell | Out-Null
    }

    # rainmeter skins in the Documents folder
    $rainmeterSkinPath = Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins\frost_hwinfo_black_white"
    if (-Not (Test-Path $rainmeterSkinPath)) {
        # the parent folders might not exist either, so create them if necessary
        if (-Not (Test-Path (Join-Path $env:USERPROFILE "Documents\Rainmeter"))) {
            New-Item -Path (Join-Path $env:USERPROFILE "Documents\Rainmeter") -ItemType Directory | Out-Null
        }
        if (-Not (Test-Path (Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins"))) {
            New-Item -Path (Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins") -ItemType Directory | Out-Null
        }
        # now create the symlink to the skin folder
        New-Item -Path $rainmeterSkinPath -ItemType SymbolicLink -Value "$env:USERPROFILE\.config\rainmeter\skins\frost_hwinfo_black_white" | Out-Null
    }

    # add chocolatey to the path
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\ProgramData\chocolatey\bin", [EnvironmentVariableTarget]::User)
}

# Ensure the profile file exists and dot-source it safely
if (-Not (Test-Path $profile)) {
    New-Item -Path $profile -ItemType File -Force | Out-Null
    Write-Host "Created profile file at $profile"
}
. $profile

komorebic stop --whkd --bar; komorebic start --whkd;

Write-Output ""
Write-Output "------------------------------------------------------------------------"
Write-Output "Done. Restart your shell to pick up on any environmental changes."
Write-Output "------------------------------------------------------------------------"

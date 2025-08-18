# This handles symbolic links, junctions, and copying files, which allows us
# to continue using the same configuration files in the repository.

If ($PSVersionTable.PSVersion.Major -Le 5 -Or $isWindows) {

    Write-Host ""
    Write-Host "Checking for symbolic links and integrations..."

    # CONFIG LINKING **********************************************************

    # Alacritty
    If ((Test-Path $env:APPDATA\Alacritty) -and (Get-Item $env:APPDATA\Alacritty).Attributes -ne "ReparsePoint") {
        Remove-Item $env:APPDATA\Alacritty -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path $env:APPDATA\Alacritty -ItemType Junction -Value $env:USERPROFILE\.config/alacritty | Out-Null
    }

    # Neovim
$nvimLocal = Join-Path $env:LOCALAPPDATA 'nvim'
$nvimConfig = Join-Path $env:USERPROFILE '.config\nvim'

if (Test-Path $nvimLocal) {
    $attributes = (Get-Item $nvimLocal).Attributes
    if ($attributes -ne "ReparsePoint") {
        Remove-Item $nvimLocal -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
    } else {
        # It's a reparse point, remove it just in case
        Remove-Item $nvimLocal -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
    }
}
if (-not (Test-Path $nvimLocal)) {
    New-Item -Path $nvimLocal -ItemType Junction -Value $nvimConfig | Out-Null
}


# Komorebi
if (-not [Environment]::GetEnvironmentVariable('KOMOREBI_CONFIG_HOME', 'User')) {
    $value = Join-Path $env:USERPROFILE '.config\komorebi'

    # Set User environment variable (correctly)
    [Environment]::SetEnvironmentVariable('KOMOREBI_CONFIG_HOME', $value, 'User')

    Write-Host "KOMOREBI_CONFIG_HOME was not set, now set to: $value"

    # Refresh environment variable in the current session
    $env:KOMOREBI_CONFIG_HOME = $value
} else {
    $current = [Environment]::GetEnvironmentVariable('KOMOREBI_CONFIG_HOME', 'User')
    Write-Host "KOMOREBI_CONFIG_HOME is already set to: $current"
}


    # Clink Scripts
    If (-Not (Test-Path $env:LOCALAPPDATA\clink)) {
        New-Item -Path $env:LOCALAPPDATA\clink -ItemType Directory | Out-Null
    }
    Copy-Item -Path $env:USERPROFILE\.config\clink\* -Destination $env:LOCALAPPDATA\clink -Recurse -Force | Out-Null

    # Automatic Shell Integration
    $psProfilePath = Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    If (-Not (Test-Path $psProfilePath)) {
        New-Item -Path $psProfilePath -ItemType File -Force | Out-Null
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

# Define Rainmeter skin path
$rainmeterSkinPath = Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins\frost_hwinfo_black_white"

# Ensure parent folders exist
if (-Not (Test-Path $rainmeterSkinPath)) {
    $skinsDir = Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins"
    if (-Not (Test-Path $skinsDir)) {
        New-Item -Path $skinsDir -ItemType Directory -Force | Out-Null
    }

    # Run only the symlink creation with elevation
    $targetPath = "$env:USERPROFILE\.config\rainmeter\skins\frost_hwinfo_black_white"
    $createSymlinkScript = @"
New-Item -Path `"$rainmeterSkinPath`" -ItemType SymbolicLink -Value `"$targetPath`" | Out-Null
"@

    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `$ErrorActionPreference = 'Stop'; $createSymlinkScript"
}


    # add chocolatey to the path
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\ProgramData\chocolatey\bin", [EnvironmentVariableTarget]::User)
}

# Ensure the profile file exists and dot-source it safely
if (-Not (Test-Path $profile)) {
    New-Item -Path $profile -ItemType File -Force | Out-Null
    Write-Host "Created profile file at $profile"
}


komorebic stop --whkd --bar; komorebic start --whkd;

Write-Output ""
Write-Output "------------------------------------------------------------------------"
Write-Output "Done. Restart your shell to pick up on any environmental changes."
Write-Output "------------------------------------------------------------------------"

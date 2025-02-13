# This links Window's configuration files back to the ~/.config directory.
#
# This is necessary because Windows uses a different location for config than
# Unix does, and we want to keep the config in the same location for all
# platforms to keep them maintainable.

If ($PSVersionTable.PSVersion.Major -Le 5 -Or $isWindows) {
    Write-Host ""
    Write-Host "- Checking for Junctions and Symbolic Links..."

    # Alacritty
    If ((Get-Item $env:APPDATA\Alacritty).Attributes -ne "ReparsePoint") {
        Remove-Item $env:APPDATA\Alacritty -Recurse -Force -Confirm:$false
        $null = New-Item -Path $env:APPDATA\Alacritty -ItemType Junction -Value $env:USERPROFILE\.config/alacritty
    }

    # Neovim
    If ((Get-Item $env:LOCALAPPDATA\nvim).Attributes -ne "ReparsePoint") {
        Remove-Item $env:LOCALAPPDATA\nvim -Recurse -Force -Confirm:$false
        $null = New-Item -Path $env:LOCALAPPDATA\nvim -ItemType Junction -Value $env:USERPROFILE\.config/nvim
    }

    # Komorebi
    If ((Get-Item $env:USERPROFILE\komorebi.json).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.json -Recurse -Force -Confirm:$false
        $null = New-Item -Path $env:USERPROFILE\komorebi.json -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.json
    }
    If ((Get-Item $env:USERPROFILE\komorebi.ps1).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.ps1 -Recurse -Force -Confirm:$false
        $null = New-Item -Path $env:USERPROFILE\komorebi.ps1 -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.ps1
    }
    If ((Get-Item $env:USERPROFILE\komorebi.generated.ps1).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.generated.ps1 -Recurse -Force -Confirm:$false
        $null = New-Item -Path $env:USERPROFILE\komorebi.generated.ps1 -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.generated.ps1
    }
    If ((Get-Item $env:USERPROFILE\komorebi.bar.json).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.bar.json -Recurse -Force -Confirm:$false
        $null = New-Item -Path $env:USERPROFILE\komorebi.bar.json -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.bar.json
    }

    # Shell Profiles
    Write-Host ""
    $overwriteProfile = Read-Host "READ CAREFULLY: Do you want to overwrite your shell profiles? (y/n)"
    If ($overwriteProfile -eq "y") {
        Copy-Item -Path $env:USERPROFILE\.local\share\chezmoi\shell_profiles\Microsoft.PowerShell_profile.ps1 -Destination $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Force
    }
}

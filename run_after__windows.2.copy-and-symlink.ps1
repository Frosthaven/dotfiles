# This handles symbolic links, junctions, and copying files, which allows us
# to continue using the same configuration files in the repository.

If ($PSVersionTable.PSVersion.Major -Le 5 -Or $isWindows) {
    Write-Host ""
    Write-Host "Checking for symbolic links and integrations..."

    # Alacritty
    If ((Get-Item $env:APPDATA\Alacritty).Attributes -ne "ReparsePoint") {
        Remove-Item $env:APPDATA\Alacritty -Recurse -Force -Confirm:$false | Out-Null
        New-Item -Path $env:APPDATA\Alacritty -ItemType Junction -Value $env:USERPROFILE\.config/alacritty | Out-Null
    }

    # Neovim
    If ((Get-Item $env:LOCALAPPDATA\nvim).Attributes -ne "ReparsePoint") {
        Remove-Item $env:LOCALAPPDATA\nvim -Recurse -Force -Confirm:$false | Out-Null
        New-Item -Path $env:LOCALAPPDATA\nvim -ItemType Junction -Value $env:USERPROFILE\.config/nvim | Out-Null
    }

    # Komorebi
    If ((Get-Item $env:USERPROFILE\komorebi.json).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.json -Recurse -Force -Confirm:$false | Out-Null
        New-Item -Path $env:USERPROFILE\komorebi.json -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.json | Out-Null
    }
    If ((Get-Item $env:USERPROFILE\komorebi.ps1).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.ps1 -Recurse -Force -Confirm:$false | Out-Null
        New-Item -Path $env:USERPROFILE\komorebi.ps1 -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.ps1 | Out-Null
    }
    If ((Get-Item $env:USERPROFILE\komorebi.generated.ps1).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.generated.ps1 -Recurse -Force -Confirm:$false | Out-Null
        New-Item -Path $env:USERPROFILE\komorebi.generated.ps1 -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.generated.ps1 | Out-Null
    }
    If ((Get-Item $env:USERPROFILE\komorebi.bar.json).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.bar.json -Recurse -Force -Confirm:$false | Out-Null
        New-Item -Path $env:USERPROFILE\komorebi.bar.json -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.bar.json | Out-Null
    }

    # Clink Scripts
    If (-Not (Test-Path $env:LOCALAPPDATA\clink)) {
        New-Item -Path $env:LOCALAPPDATA\clink -ItemType Directory | Out-Null
    }
    Copy-Item -Path $env:USERPROFILE\.config\clink\* -Destination $env:LOCALAPPDATA\clink -Recurse -Force | Out-Null

    # Automatic Shell Integration
    If (-Not (Test-Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1)) {
        New-Item -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -ItemType File | Out-Null
    }
    If (-Not (Select-String -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Pattern "chezmoi-powershell.ps1")) {
        Add-Content -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Value "# Load Chezmoi PowerShell profile" | Out-Null
        Add-Content -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Value ". '$env:USERPROFILE\.config\shell\powershell\chezmoi-powershell.ps1'" | Out-Null
    }

    # Automatic Zoxide Integration
    If (-Not (Select-String -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Pattern "chezmoi-powershell-zoxide.ps1")) {
        Add-Content -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Value "# Load Zoxide PowerShell profile" | Out-Null
        Add-Content -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Value ". '$env:USERPROFILE\.config\shell\powershell\chezmoi-powershell-zoxide.ps1'" | Out-Null
    }

    # Nushell
    If ((Get-Item $env:APPDATA\nushell).Attributes -ne "ReparsePoint") {
        Remove-Item $env:APPDATA\nushell -Recurse -Force -Confirm:$false | Out-Null
        New-Item -Path $env:APPDATA\nushell -ItemType Junction -Value $env:USERPROFILE\.config\shell\nushell | Out-Null
    }

    # rainmeter skins in the Documents folder
    If (-Not (Test-Path $env:USERPROFILE\Documents\Rainmeter\Skins\frost_hwinfo_black_white)) {
        # the parent folders might not exist either, so create them if necessary
        If (-Not (Test-Path $env:USERPROFILE\Documents\Rainmeter)) {
            New-Item -Path $env:USERPROFILE\Documents\Rainmeter -ItemType Directory | Out-Null
        }

        If (-Not (Test-Path $env:USERPROFILE\Documents\Rainmeter\Skins)) {
            New-Item -Path $env:USERPROFILE\Documents\Rainmeter\Skins -ItemType Directory | Out-Null
        }

        # now create the symlink to the skin folder
        New-Item -Path $env:USERPROFILE\Documents\Rainmeter\Skins\frost_hwinfo_black_white -ItemType SymbolicLink -Value $env:USERPROFILE\.config\rainmeter\skins\frost_hwinfo_black_white | Out-Null
    }
}

# source the shell profile
. $profile
komorebic stop --whkd --bar; komorebic start --whkd;

echo ""
echo "------------------------------------------------------------------------"
echo "Done. Restart your shell to pick up on any environmental changes."
echo "------------------------------------------------------------------------"


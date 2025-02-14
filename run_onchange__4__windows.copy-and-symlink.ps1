# This handles symbolic links, junctions, and copying files, which allows us
# to continue using the same configuration files in the repository.

If ($PSVersionTable.PSVersion.Major -Le 5 -Or $isWindows) {
    Write-Host ""
    Write-Host "- Checking for Junctions and Symbolic Links..."

    # Alacritty
    If ((Get-Item $env:APPDATA\Alacritty).Attributes -ne "ReparsePoint") {
        Remove-Item $env:APPDATA\Alacritty -Recurse -Force -Confirm:$false
        New-Item -Path $env:APPDATA\Alacritty -ItemType Junction -Value $env:USERPROFILE\.config/alacritty
    }

    # Neovim
    If ((Get-Item $env:LOCALAPPDATA\nvim).Attributes -ne "ReparsePoint") {
        Remove-Item $env:LOCALAPPDATA\nvim -Recurse -Force -Confirm:$false
        New-Item -Path $env:LOCALAPPDATA\nvim -ItemType Junction -Value $env:USERPROFILE\.config/nvim
    }

    # Komorebi
    If ((Get-Item $env:USERPROFILE\komorebi.json).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.json -Recurse -Force -Confirm:$false
        New-Item -Path $env:USERPROFILE\komorebi.json -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.json
    }
    If ((Get-Item $env:USERPROFILE\komorebi.ps1).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.ps1 -Recurse -Force -Confirm:$false
        New-Item -Path $env:USERPROFILE\komorebi.ps1 -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.ps1
    }
    If ((Get-Item $env:USERPROFILE\komorebi.generated.ps1).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.generated.ps1 -Recurse -Force -Confirm:$false
        New-Item -Path $env:USERPROFILE\komorebi.generated.ps1 -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.generated.ps1
    }
    If ((Get-Item $env:USERPROFILE\komorebi.bar.json).Attributes -ne "ReparsePoint") {
        Remove-Item $env:USERPROFILE\komorebi.bar.json -Recurse -Force -Confirm:$false
        New-Item -Path $env:USERPROFILE\komorebi.bar.json -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.bar.json
    }

    # Clink Scripts
    If (-Not (Test-Path $env:LOCALAPPDATA\clink)) {
        New-Item -Path $env:LOCALAPPDATA\clink -ItemType Directory
    }
    Copy-Item -Path $env:USERPROFILE\.config\clink\* -Destination $env:LOCALAPPDATA\clink -Recurse -Force

    # Automatic Shell Integration
    If (-Not (Test-Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1)) {
        New-Item -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -ItemType File
    }
    If (-Not (Select-String -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Pattern "chezmoi-powershell.ps1")) {
        Add-Content -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Value "# Load Chezmoi PowerShell profile"
        Add-Content -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Value ". '$env:USERPROFILE\.config\shell\chezmoi-powershell.ps1'"
    }

    # Automatic Zoxide Integration
    If (-Not (Select-String -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Pattern "chezmoi-powershell-zoxide.ps1")) {
        Add-Content -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Value "# Load Zoxide PowerShell profile"
        Add-Content -Path $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Value ". '$env:USERPROFILE\.config\shell\chezmoi-powershell-zoxide.ps1'"
    }

}


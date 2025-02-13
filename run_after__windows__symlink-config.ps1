# This links Window's configuration files back to the ~/.config directory.
#
# This is necessary because Windows uses a different location for config than
# Unix does, and we want to keep the config in the same location for all
# platforms to keep them maintainable.

If ($PSVersionTable.PSVersion.Major -Le 5 -Or $isWindows) {

    # Alacritty
    If (-Not (Test-Path $env:APPDATA\Alacritty)) {
        New-Item -Path $env:APPDATA\Alacritty -ItemType Junction -Value $env:USERPROFILE\.config/alacritty
    }

    # Neovim
    If (-Not (Test-Path $env:LOCALAPPDATA\nvim)) {
        New-Item -Path $env:LOCALAPPDATA\nvim -ItemType Junction -Value $env:USERPROFILE\.config/nvim
    }

    # Komorebi
    If (-Not (Test-Path $env:USERPROFILE\komorebi.json)) {
        New-Item -Path $env:USERPROFILE\komorebi.json -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.json
    }
    If (-Not (Test-Path $env:USERPROFILE\komorebi.ps1)) {
        New-Item -Path $env:USERPROFILE\komorebi.ps1 -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.ps1
    }
    If (-Not (Test-Path $env:USERPROFILE\komorebi.generated.ps1)) {
        New-Item -Path $env:USERPROFILE\komorebi.generated.ps1 -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.generated.ps1
    }
    If (-Not (Test-Path $env:USERPROFILE\komorebi.bar.json)) {
        New-Item -Path $env:USERPROFILE\komorebi.bar.json -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.bar.json
    }

}

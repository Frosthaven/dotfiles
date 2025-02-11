# This links Window's komorebi config to the location Unix uses.
#
# This is necessary because Windows uses a different location for config than
# Unix does, and we want to keep the config in the same location for all
# platforms.

If ($PSVersionTable.PSVersion.Major -Le 5 -Or $isWindows) {
    # komorebi file links
    If (-Not (Test-Path $env:USERPROFILE\komorebi.json)) {
        New-Item -Path $env:USERPROFILE\komorebi.json -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.json
    }
    If (-Not (Test-Path $env:USERPROFILE\komorebi.ps1)) {
        New-Item -Path $env:USERPROFILE\komorebi.ps1 -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.ps1
    }
    If (-Not (Test-Path $env:USERPROFILE\komorebi.generated.ps1)) {
        New-Item -Path $env:USERPROFILE\komorebi.generated.ps1 -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.generated.ps1
    }
    If (-Not (Test-Path $env:USERPROFILE\komorebi.ahk)) {
        New-Item -Path $env:USERPROFILE\komorebi.ahk -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.ahk
    }

    # komorebi bar file links
    If (-Not (Test-Path $env:USERPROFILE\komorebi.bar.json)) {
        New-Item -Path $env:USERPROFILE\komorebi.bar.json -ItemType SymbolicLink -Value $env:USERPROFILE\.config\komorebi\komorebi.bar.json
    }
}

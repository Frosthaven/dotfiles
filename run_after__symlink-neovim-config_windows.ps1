# this links Window's nvim config to the location Unix uses
# this is necessary because Windows uses a different location for nvim config
# than Unix does, and we want to keep the config in the same location for all
# platforms

If ($PSVersionTable.PSVersion.Major -Le 5 -Or $isWindows) {
    If (-Not (Test-Path $env:LOCALAPPDATA\nvim)) {
        New-Item -Path $env:LOCALAPPDATA\nvim -ItemType Junction -Value $env:USERPROFILE\.config/nvim
    }
}
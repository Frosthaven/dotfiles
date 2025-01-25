# This links Window's nvim config to the location Unix uses.
#
# This is necessary because Windows uses a different location for config than
# Unix does, and we want to keep the config in the same location for all
# platforms.

If ($PSVersionTable.PSVersion.Major -Le 5 -Or $isWindows) {
    If (-Not (Test-Path $env:APPDATA\Alacritty)) {
        New-Item -Path $env:APPDATA\Alacritty -ItemType Junction -Value $env:USERPROFILE\.config/alacritty
    }
}
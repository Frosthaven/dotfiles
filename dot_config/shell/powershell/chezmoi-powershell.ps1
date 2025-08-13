# SHELL PROFILE: POWERSHELL ***************************************************
# *****************************************************************************

# To use, source this file in your shell profile. Usually located here:
# $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# CONTENTS ********************************************************************
# *****************************************************************************

# Predictive Text Setup (REQUIRES powershell ^7.2)
# First, run this in Admin session:
# - Install-Module PSReadLine -Force
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -Colors @{ InlinePrediction = '#5A6374'}

# Starship
Invoke-Expression (&starship init powershell)

# Module: CommandNotFound
Import-Module -Name Microsoft.WinGet.CommandNotFound

# Wezterm: Enable OC7 Escape Sequence Support
# see: https://wezfurlong.org/wezterm/shell-integration.html#osc-7-on-windows-with-cmdexe
$prompt = ""
function Invoke-Starship-PreCommand {
    $current_location = $executionContext.SessionState.Path.CurrentLocation
    if ($current_location.Provider.Name -eq "FileSystem") {
        $ansi_escape = [char]27
        $provider_path = $current_location.ProviderPath -replace "\\", "/"
        $prompt = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}$ansi_escape\"
    }
    $host.ui.Write($prompt)
}

# fnm
if (-not $env:FNM_DIR) {
    # setup environment
    $output = (fnm env | Out-String).Trim()
    Invoke-Expression $output
    # install the latest version
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        fnm install --lts
        fnm use lts-latest
    }
}

# UV binaries
$env:Path += ";$env:USERPROFILE\.local\bin"

# fzf - [s]earch [f]iles command (sf)
# this will use the output of the fzf command to open the file in nvim. You can
# change the editor launch command to whatever you want.
# see: https://github.com/junegunn/fzf
# see: https://github.com/sharkdp/bat
function sf {
    $file = fzf --preview "bat --color=always {}" --preview-window=right:50%:wrap --height 50% --border --prompt="Search Files: " --query="$args"
    if ($file) {
        nvim $file # or with your editor of choice
    }
}

# ALIASES *********************************************************************
# *****************************************************************************
function docmd { cmd /c $args }

# eza
function alias-l { docmd "eza --icons=always" }
Set-Alias -Name l -Value alias-l -Force
function alias-ls { docmd "eza --icons=always --group --header --group-directories-first" }
Set-Alias -Name ls -Value alias-ls -Force
function alias-ll { docmd "eza --icons=always --long" }
Set-Alias -Name ll -Value alias-ll -Force
function alias-lg { docmd "eza --icons=always --group --header --group-directories-first --long --git" }
Set-Alias -Name lg -Value alias-lg -Force
function alias-le { docmd "eza --icons=always --group --header --group-directories-first --long --extended" }
Set-Alias -Name le -Value alias-le -Force
function alias-lt { docmd "eza --icons=always --group --header --group-directories-first --tree --level 2" }
Set-Alias -Name lt -Value alias-lt -Force
function alias-lc { docmd "eza --icons=always --group --header --group-directories-first --across" }
Set-Alias -Name lc -Value alias-lc -Force
function alias-lo { docmd "eza --icons=always --group --header --group-directories-first --oneline" }
Set-Alias -Name lo -Value alias-lo -Force
function alias-la { docmd "eza --icons=always --all" }
Set-Alias -Name la -Value alias-la -Force
function alias-lsa { docmd "eza --icons=always --group --header --group-directories-first --all" }
Set-Alias -Name lsa -Value alias-lsa -Force
function alias-lla { docmd "eza --icons=always --group --header --group-directories-first --all --long --git" }
Set-Alias -Name lla -Value alias-lla -Force
function alias-lga { docmd "eza --icons=always --group --header --group-directories-first --all --long --git --git-ignore" }
Set-Alias -Name lga -Value alias-lga -Force

# add $HOME/.local/bin binaries to PATH
$env:Path += ";$env:USERPROFILE\.local\bin"

# Add cargo to path
$env:Path += ";$env:USERPROFILE\.cargo\bin"

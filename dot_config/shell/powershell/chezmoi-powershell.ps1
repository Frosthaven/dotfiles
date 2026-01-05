# SHELL PROFILE: POWERSHELL ***************************************************
# *****************************************************************************

# To use, source this file in your shell profile. Usually located here:
# $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# CONTENTS ********************************************************************
# *****************************************************************************

# Predictive Text Setup (REQUIRES powershell ^7.2)
# First, run this in Admin session:
# - Install-Module PSReadLine -Force


if ($PSVersionTable.PSVersion.Major -ge 7) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -Colors @{ InlinePrediction = '#5A6374'}
}

# Starship
Invoke-Expression (&starship init powershell)

# Module: CommandNotFound
if (Get-Module -ListAvailable -Name Microsoft.WinGet.CommandNotFound) {
    Import-Module Microsoft.WinGet.CommandNotFound
}

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

# nvim-bob binaries
$env:Path += ";$env:LOCALAPPDATA\bob\nightly\bin;$env:USERPROFILE\.local\share\bob\nvim-bin"

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
New-Alias -Name l -Value alias-l -Force
function alias-ls { docmd "eza --icons=always --group --header --group-directories-first" }
Set-Alias -Name ls -Value alias-ls -Force -Option AllScope
function alias-ll { docmd "eza --icons=always --long" }
New-Alias -Name ll -Value alias-ll -Force
function alias-lg { docmd "eza --icons=always --group --header --group-directories-first --long --git" }
New-Alias -Name lg -Value alias-lg -Force
function alias-le { docmd "eza --icons=always --group --header --group-directories-first --long --extended" }
New-Alias -Name le -Value alias-le -Force
function alias-lt { docmd "eza --icons=always --group --header --group-directories-first --tree --level 2" }
New-Alias -Name lt -Value alias-lt -Force
function alias-lc { docmd "eza --icons=always --group --header --group-directories-first --across" }
New-Alias -Name lc -Value alias-lc -Force
function alias-lo { docmd "eza --icons=always --group --header --group-directories-first --oneline" }
New-Alias -Name lo -Value alias-lo -Force
function alias-la { docmd "eza --icons=always --all" }
New-Alias -Name la -Value alias-la -Force
function alias-lsa { docmd "eza --icons=always --group --header --group-directories-first --all" }
New-Alias -Name lsa -Value alias-lsa -Force
function alias-lla { docmd "eza --icons=always --group --header --group-directories-first --all --long --git" }
New-Alias -Name lla -Value alias-lla -Force
function alias-lga { docmd "eza --icons=always --group --header --group-directories-first --all --long --git --git-ignore" }
New-Alias -Name lga -Value alias-lga -Force

# add $HOME/.local/bin binaries to PATH
$env:Path += ";$env:USERPROFILE\.local\bin"

# Add cargo to path
$env:Path += ";$env:USERPROFILE\.cargo\bin"

# Add PNPM to path
$env:PNPM_HOME = "$env:USERPROFILE\.local\share\pnpm"
$env:Path += ";$env:USERPROFILE\.local\share\pnpm"

# SSH AGENT + PROTON PASS *****************************************************
# *****************************************************************************
# Set PROTON_PASS_LOGGED_IN based on pass-cli status

function Initialize-SshAgent {
    # Start ssh-agent if not running
    $sshAgent = Get-Process ssh-agent -ErrorAction SilentlyContinue
    if (-not $sshAgent) {
        Start-Service ssh-agent -ErrorAction SilentlyContinue
    }

    # Check if pass-cli is available
    $passCli = Get-Command pass-cli -ErrorAction SilentlyContinue
    if (-not $passCli) {
        return
    }

    # Set PROTON_PASS_LOGGED_IN based on login status
    $loginStatus = pass-cli info 2>&1
    if ($LASTEXITCODE -eq 0) {
        $env:PROTON_PASS_LOGGED_IN = "true"
    } else {
        $env:PROTON_PASS_LOGGED_IN = "false"
    }
}

Initialize-SshAgent

# RCLONE **********************************************************************
# *****************************************************************************
# Wrapper: lazy load rclone password on first use

function rclone {
    # Lazy load password if not set
    if (-not $env:RCLONE_CONFIG_PASS) {
        $passCli = Get-Command pass-cli -ErrorAction SilentlyContinue
        if ($passCli) {
            try {
                $password = pass-cli item view "pass://Personal/rclone/password" --field password 2>&1
                if ($LASTEXITCODE -eq 0 -and $password) {
                    $env:RCLONE_CONFIG_PASS = $password
                }
            } catch {
                # Silently ignore errors
            }
        }
    }
    # Call the actual rclone binary
    & (Get-Command rclone -CommandType Application) @args
}

# Helper function: Edit rclone config and re-add to chezmoi
function rclone-config {
    rclone config
    if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
        $rcloneConfigPath = "$env:USERPROFILE\.config\rclone\rclone.conf"
        if (Test-Path $rcloneConfigPath) {
            Write-Host "Syncing rclone config to chezmoi..."
            chezmoi re-add $rcloneConfigPath
            chezmoi git -- add dot_config/rclone/private_rclone.conf
            chezmoi git commit -m "chore: update rclone config"
            
            # Auto-push if only 1 commit ahead, otherwise warn user
            $aheadCount = chezmoi git -- rev-list --count "@{u}..HEAD" 2>$null
            if ($aheadCount -eq "1") {
                chezmoi git push
                Write-Host "Done. Changes pushed to remote."
            } else {
                Write-Host "Done. Multiple unpushed commits detected - run 'chezmoi git push' to sync to remote."
            }
        }
    }
}

# Source additional functions
. "$env:USERPROFILE\.config\shell\powershell\sources\pass-ssh-unpack.ps1"
. "$env:USERPROFILE\.config\shell\powershell\sources\system-update.ps1"

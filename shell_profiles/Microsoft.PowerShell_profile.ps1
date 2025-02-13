# Predictive Text Setup (REQUIRES powershell ^7.2)
# First, run this in Admin session:
# - Install-Module PSReadLine -Force
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -Colors @{ InlinePrediction = '#5A6374'}

# Starship
Invoke-Expression (&starship init powershell)
#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58

# Adds OC7 Escape Sequence Support
# https://wezfurlong.org/wezterm/shell-integration.html#osc-7-on-windows-with-cmdexe
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

# Add Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

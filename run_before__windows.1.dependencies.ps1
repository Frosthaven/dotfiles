# Ensure chocolatey and scoop are both installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "Chocolatey installed successfully."
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop is not installed. Installing Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser;
    iwr get.scoop.sh -useb | iex
    Write-Host "Scoop installed successfully."
}

# PATH *********************************************************************
# ensure that we have the following directories in the path variable:
function Test-IsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Get-MissingPaths {
    param(
        [string[]]$paths,
        [EnvironmentVariableTarget]$target
    )
    $existingPath = [Environment]::GetEnvironmentVariable("Path", $target)
    $existingEntries = @()
    if ($existingPath) {
        $existingEntries = $existingPath -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    }

    return $paths | Where-Object {
        $p = $_.Trim()
        -not ($existingEntries -contains $p) -and (Test-Path $p)
    }
}

function Add-PathsToEnvironmentVariable {
    param(
        [string]$variableName,
        [EnvironmentVariableTarget]$target,
        [string[]]$paths
    )

    $existingPath = [Environment]::GetEnvironmentVariable($variableName, $target)
    $existingEntries = @()
    if ($existingPath) {
        $existingEntries = $existingPath -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    }

    $missingPaths = $paths | Where-Object {
        $p = $_.Trim()
        -not ($existingEntries -contains $p) -and (Test-Path $p)
    }

    if ($missingPaths.Count -gt 0) {
        $newPath = $existingPath + ';' + ($missingPaths -join ';')
        $newPath = $newPath.TrimEnd(';')
        [Environment]::SetEnvironmentVariable($variableName, $newPath, $target)
        Write-Host "Updated $variableName ($target) to include: $($missingPaths -join ', ')"
        return $true
    } else {
        # Write-Host "$variableName ($target) already contains all paths."
        return $false
    }
}

# Your paths to add
$pathsToAdd = @(
    (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links"),
    (Join-Path $env:USERPROFILE ".cargo\bin"),
    "$env:USERPROFILE\.local\bin",
    "$env:PROGRAMDATA\chocolatey\bin"
)

# Add to User PATH (no elevation needed)
Add-PathsToEnvironmentVariable -variableName "Path" -target ([EnvironmentVariableTarget]::User) -paths $pathsToAdd | Out-Null

# Check missing System PATH entries BEFORE elevation
$missingSystemPaths = Get-MissingPaths -paths $pathsToAdd -target ([EnvironmentVariableTarget]::Machine)

if ($missingSystemPaths.Count -gt 0) {
    if (-not (Test-IsAdmin)) {
        # Build the script block for elevated process, passing missing paths only
        $escapedPaths = $missingSystemPaths -replace "'", "''" # Escape single quotes
        $scriptBlock = @"
`$paths = @(
    '$($escapedPaths -join "','")'
)
`$existingPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
`$existingEntries = if (`$existingPath) { `$existingPath -split ';' | ForEach-Object { `$_.Trim() } } else { @() }
`$missing = `$paths | Where-Object { -not (`$existingEntries -contains `$_) -and (Test-Path `$_) }
if (`$missing.Count -gt 0) {
    `$newPath = `$existingPath + ';' + (`$missing -join ';')
    `$newPath = `$newPath.TrimEnd(';')
    [Environment]::SetEnvironmentVariable('Path', `$newPath, [EnvironmentVariableTarget]::Machine)
    Write-Host 'System PATH updated to include: ' + (`$missing -join ', ')
} else {
    # Write-Host 'No missing paths detected in System PATH.'
}
Start-Sleep -Seconds 2
exit
"@

        Write-Host "Requesting elevation to update System PATH..."
        Start-Process powershell.exe -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $scriptBlock -Verb RunAs
    }
    else {
        # Already admin, just update directly
        Add-PathsToEnvironmentVariable -variableName "Path" -target ([EnvironmentVariableTarget]::Machine) -paths $missingSystemPaths | Out-Null
    }
} else {
    # Write-Host "System PATH already contains all paths; no elevation needed."
}

# Update current session PATH to reflect new entries immediately
$envPaths = $env:Path -split ';' | ForEach-Object { $_.Trim() }
foreach ($p in $pathsToAdd) {
    if (-not ($envPaths -contains $p) -and (Test-Path $p)) {
        $env:Path += ";$p"
    }
}

# Add to User PATH
Add-PathsToEnvironmentVariable -variableName "Path" -target ([EnvironmentVariableTarget]::User) -paths $pathsToAdd | Out-Null

# Update current session PATH environment variable to reflect changes
$envPaths = $env:Path -split ';' | ForEach-Object { $_.Trim() }
foreach ($p in $pathsToAdd) {
    if (-not ($envPaths -contains $p) -and (Test-Path $p)) {
        $env:Path += ";$p"
    }
}


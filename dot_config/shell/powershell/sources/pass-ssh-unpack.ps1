# pass-ssh-unpack wrapper: Syncs chezmoi after running the binary
# See: docs/pass-ssh-unpack.md

function pass-ssh-unpack {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    # Find the binary
    $binaryPath = $null
    
    if (Get-Command pass-ssh-unpack-bin -ErrorAction SilentlyContinue) {
        $binaryPath = "pass-ssh-unpack-bin"
    } elseif (Test-Path "$env:USERPROFILE\.cargo\bin\pass-ssh-unpack.exe") {
        $binaryPath = "$env:USERPROFILE\.cargo\bin\pass-ssh-unpack.exe"
    } elseif (Test-Path "$HOME/.cargo/bin/pass-ssh-unpack") {
        $binaryPath = "$HOME/.cargo/bin/pass-ssh-unpack"
    } else {
        Write-Host "(pass-ssh-unpack) Binary not found. Install with: cargo install pass-ssh-unpack" -ForegroundColor Red
        return
    }

    # Run the actual binary with rclone password path
    & $binaryPath --rclone-password-path "pass://Personal/rclone/password" @Arguments
    $exitCode = $LASTEXITCODE

    # Skip chezmoi sync if command failed
    if ($exitCode -ne 0) {
        return
    }

    # Skip chezmoi sync if dry-run
    if ($Arguments -contains "--dry-run") {
        return
    }

    # Skip chezmoi sync if chezmoi not available
    if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
        return
    }

    # Check if rclone config is managed by chezmoi
    $managed = chezmoi managed 2>$null
    if (-not ($managed -match "rclone/rclone.conf")) {
        return
    }

    # Re-add rclone config
    $rcloneConf = if ($IsWindows -or $env:OS -match "Windows") {
        "$env:USERPROFILE\.config\rclone\rclone.conf"
    } else {
        "$HOME/.config/rclone/rclone.conf"
    }
    chezmoi re-add $rcloneConf 2>$null

    # Check if there are changes to commit
    $diffResult = chezmoi git -- diff --quiet dot_config/rclone/private_rclone.conf 2>$null
    if ($LASTEXITCODE -eq 0) {
        # No changes
        return
    }

    # Commit changes
    chezmoi git -- add dot_config/rclone/private_rclone.conf 2>$null
    chezmoi git -- commit -m "chore: update rclone config via pass-ssh-unpack" 2>$null

    # Check how many commits ahead
    $aheadCount = chezmoi git -- rev-list --count "@{u}..HEAD" 2>$null
    if (-not $aheadCount) { $aheadCount = "0" }

    if ($aheadCount -eq "1") {
        chezmoi git push 2>$null
        Write-Host "  Synced rclone config to chezmoi (committed and pushed)."
    } elseif ([int]$aheadCount -gt 1) {
        Write-Host "  Synced rclone config to chezmoi ($aheadCount commits ahead - run 'chezmoi git push' to sync)."
    } else {
        Write-Host "  Synced rclone config to chezmoi."
    }
}

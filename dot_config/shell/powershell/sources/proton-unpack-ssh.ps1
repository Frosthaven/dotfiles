# proton-unpack-ssh: Generate SSH public keys from Proton Pass
# - Extracts public keys from private keys stored in Proton Pass
# - Saves them to ~/.ssh/from-proton/<vault>/<keyname>.pub
# - Generates ~/.ssh/from-proton/config with IdentityFile mappings
# - Saves generated public keys back to Proton Pass if empty
# - Supports User and Aliases fields for complete SSH config generation

function proton-unpack-ssh {
    # Check if pass-cli is available
    $passCli = Get-Command pass-cli -ErrorAction SilentlyContinue
    if (-not $passCli) {
        Write-Host "(proton-unpack-ssh) pass-cli not found. Install Proton Pass CLI first." -ForegroundColor Red
        return
    }

    # Check if logged into Proton Pass
    $null = pass-cli info 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "(proton-unpack-ssh) Not logged into Proton Pass. Run 'pass-cli login' first." -ForegroundColor Red
        return
    }

    # Check if ssh-keygen is available
    $sshKeygen = Get-Command ssh-keygen -ErrorAction SilentlyContinue
    if (-not $sshKeygen) {
        Write-Host "(proton-unpack-ssh) ssh-keygen not found. Install OpenSSH first." -ForegroundColor Red
        return
    }

    Write-Host "Generating SSH public keys from Proton Pass..."
    Write-Host ""

    # Get hostname for duplicate key matching
    $currentHostname = $env:COMPUTERNAME.ToLower()

    # Create base directory
    $baseDir = Join-Path $env:USERPROFILE ".ssh\from-proton"
    if (-not (Test-Path $baseDir)) {
        New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
    }

    # Initialize config file
    $configPath = Join-Path $baseDir "config"
    @(
        "# Auto-generated from Proton Pass SSH keys",
        "# Do not edit - regenerate with: proton-unpack-ssh"
    ) | Set-Content -Path $configPath

    # Get all vaults
    $vaultsJson = pass-cli vault list --output json | ConvertFrom-Json
    $vaults = $vaultsJson.vaults | ForEach-Object { $_.name }

    # Track host -> key mappings
    # Each entry: @{Host, Title, Path, User}
    $hostKeys = @()

    foreach ($vault in $vaults) {
        if ([string]::IsNullOrEmpty($vault)) { continue }

        Write-Host "[$vault]"

        # Get SSH keys in this vault
        $keysJson = pass-cli item list $vault --filter-type ssh-key --output json 2>$null
        if ([string]::IsNullOrEmpty($keysJson)) {
            Write-Host "  (no SSH keys)"
            Write-Host ""
            continue
        }

        try {
            $keys = $keysJson | ConvertFrom-Json
        } catch {
            Write-Host "  (no SSH keys)"
            Write-Host ""
            continue
        }

        if (-not $keys.items -or $keys.items.Count -eq 0) {
            Write-Host "  (no SSH keys)"
            Write-Host ""
            continue
        }

        # Create vault directory
        $vaultDir = Join-Path $baseDir $vault
        if (-not (Test-Path $vaultDir)) {
            New-Item -ItemType Directory -Path $vaultDir -Force | Out-Null
        }

        foreach ($item in $keys.items) {
            $title = $item.content.title
            Write-Host "  Processing: $title"

            $privateKey = $item.content.content.SshKey.private_key
            $existingPubkey = $item.content.content.SshKey.public_key

            # Get fields from extra_fields
            $hostField = $null
            $usernameField = $null
            $aliasField = $null
            $aliasesField = $null
            foreach ($field in $item.content.extra_fields) {
                if ($field.name -eq "Host" -and $field.content.Text) {
                    $hostField = $field.content.Text
                }
                if ($field.name -eq "Username" -and $field.content.Text) {
                    $usernameField = $field.content.Text
                }
                if ($field.name -eq "Aliases" -and $field.content.Text) {
                    $aliasesField = $field.content.Text
                }
            }

            if ([string]::IsNullOrEmpty($hostField)) {
                Write-Host "    -> skipped (no Host field)"
                continue
            }

            # Sanitize title for filename
            $safeTitle = $title -replace '/', '-' -replace ' ', '_'

            # Generate public key using temp file (Windows doesn't support /dev/stdin)
            $tempKeyFile = [System.IO.Path]::GetTempFileName()
            $pubkeyPath = Join-Path $vaultDir "$safeTitle.pub"

            try {
                # Write private key to temp file with trailing newline
                "$privateKey`n" | Set-Content -Path $tempKeyFile -NoNewline

                # Generate public key
                $generatedPubkey = ssh-keygen -y -f $tempKeyFile 2>$null
                if ($LASTEXITCODE -eq 0 -and $generatedPubkey) {
                    $generatedPubkey | Set-Content -Path $pubkeyPath -NoNewline

                    # Save public key back to Proton Pass if empty
                    if ([string]::IsNullOrEmpty($existingPubkey)) {
                        $null = pass-cli item update --vault-name $vault --item-title $title --field "public_key=$generatedPubkey" 2>&1
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "    -> $safeTitle.pub (saved to Proton Pass)"
                        } else {
                            Write-Host "    -> $safeTitle.pub (failed to save to Proton Pass)"
                        }
                    } else {
                        Write-Host "    -> $safeTitle.pub"
                    }

                    # Build list of hosts (main host + aliases)
                    # If no Aliases field, use the item title as an alias
                    $allHosts = @($hostField)
                    if (-not [string]::IsNullOrEmpty($aliasesField)) {
                        $aliases = $aliasesField -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
                        $allHosts += $aliases
                    } else {
                        # Use title as fallback alias
                        $allHosts += $title
                    }

                    # Track for duplicate handling
                    foreach ($h in $allHosts) {
                        if ([string]::IsNullOrEmpty($h)) { continue }
                        $hostKeys += @{
                            Host = $h
                            Title = $title
                            Path = $pubkeyPath
                            User = $usernameField
                        }
                    }
                } else {
                    Write-Host "    -> failed to generate public key"
                }
            } finally {
                # Clean up temp file
                if (Test-Path $tempKeyFile) {
                    Remove-Item $tempKeyFile -Force
                }
            }
        }

        Write-Host ""
    }

    # Generate SSH config entries
    Write-Host "Generating SSH config..."

    # Get unique hosts
    $uniqueHosts = $hostKeys | ForEach-Object { $_.Host } | Sort-Object -Unique

    foreach ($h in $uniqueHosts) {
        $keysForHost = $hostKeys | Where-Object { $_.Host -eq $h }
        $selectedKey = $null

        if ($keysForHost.Count -gt 1) {
            # Try to find key matching hostname
            $matching = $keysForHost | Where-Object { $_.Title.ToLower() -like "*$currentHostname*" } | Select-Object -First 1
            if ($matching) {
                $selectedKey = $matching
            } else {
                # Fallback to first key
                $selectedKey = $keysForHost | Select-Object -First 1
            }
        } else {
            $selectedKey = $keysForHost | Select-Object -First 1
        }

        # Append to config (use forward slashes for SSH config compatibility, quote for spaces)
        $selectedPathUnix = $selectedKey.Path -replace '\\', '/'
        Add-Content -Path $configPath -Value ""
        Add-Content -Path $configPath -Value "Host $h"
        Add-Content -Path $configPath -Value "    IdentityFile `"$selectedPathUnix`""
        Add-Content -Path $configPath -Value "    IdentitiesOnly yes"
        if (-not [string]::IsNullOrEmpty($selectedKey.User)) {
            Add-Content -Path $configPath -Value "    User $($selectedKey.User)"
        }
    }

    $totalKeys = $uniqueHosts.Count

    Write-Host ""
    Write-Host "Done! Generated config for $totalKeys hosts."
    Write-Host "SSH config written to: $configPath"
}

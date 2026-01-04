# pass-ssh-unpack: Extract SSH keys from Proton Pass to local files
# See: docs/pass-ssh-unpack.md

# Helper: Check if title matches any pattern (glob-style wildcards)
def matches-pattern [title: string, patterns: list<string>]: nothing -> bool {
    if ($patterns | is-empty) {
        return true
    }
    
    for pattern in $patterns {
        # Convert glob pattern to regex
        let regex_pattern = ($pattern | str replace -a '*' '.*' | str replace -a '?' '.')
        if ($title =~ $regex_pattern) {
            return true
        }
    }
    return false
}

# Extract SSH keys from Proton Pass to local files and generate SSH config.
#
# Examples:
#   pass-ssh-unpack                                  # All vaults, all keys
#   pass-ssh-unpack -v Personal                      # Single vault
#   pass-ssh-unpack -v "Dragon*"                     # Vaults matching pattern
#   pass-ssh-unpack -v [Personal "Dragon Servers"]   # Multiple vaults
#   pass-ssh-unpack -i 'github/*'                    # Keys matching pattern
#   pass-ssh-unpack -i ['github/*' 'thedragon*']     # Multiple patterns
#   pass-ssh-unpack --full                           # Full regeneration
#   pass-ssh-unpack --no-rclone                      # Skip rclone sync
#   pass-ssh-unpack --purge                          # Remove all managed data
def pass-ssh-unpack [
    --vault (-v): any   # Vault(s) to process - string or list, supports * and ? wildcards
    --item (-i): any    # Item title pattern(s) - string or list, supports * and ? wildcards
    --full (-f)         # Full regeneration (clear config first)
    --quiet (-q)        # Suppress output
    --no-rclone         # Skip rclone remote sync
    --purge             # Remove all managed SSH keys and rclone remotes, then exit
] {
    # Normalize inputs to lists
    let vault_filter = if ($vault | is-empty) {
        []
    } else if ($vault | describe | str starts-with "list") {
        $vault
    } else {
        [$vault]
    }
    
    let patterns = if ($item | is-empty) {
        []
    } else if ($item | describe | str starts-with "list") {
        $item
    } else {
        [$item]
    }
    
    # Helper function for output
    def log [msg: string] {
        if not $quiet {
            print $msg
        }
    }
    
    # =========================================================================
    # Dependency checks
    # =========================================================================
    if (which pass-cli | is-empty) {
        print "(pass-ssh-unpack) pass-cli not found. Install Proton Pass CLI first."
        return
    }
    
    let login_check = (do { pass-cli info } | complete)
    if $login_check.exit_code != 0 {
        print "(pass-ssh-unpack) Not logged into Proton Pass. Run 'pass-cli login' first."
        return
    }
    
    if (which ssh-keygen | is-empty) {
        print "(pass-ssh-unpack) ssh-keygen not found. Install OpenSSH first."
        return
    }
    
    # =========================================================================
    # Purge mode: delete everything and exit
    # =========================================================================
    if $purge {
        let base_dir = ($env.HOME | path join ".ssh" "proton-pass")
        
        log "Purging all managed SSH keys and rclone remotes..."
        
        # Delete SSH keys folder
        if ($base_dir | path exists) {
            rm -rf $base_dir
            log $"  Removed ($base_dir)"
        } else {
            log $"  ($base_dir) does not exist"
        }
        
        # Delete managed rclone remotes
        if (which rclone | is-not-empty) {
            mut rclone_pass = ($env.RCLONE_CONFIG_PASS? | default "")
            if ($rclone_pass | is-empty) {
                let pass_result = (do { pass-cli item view "pass://Personal/rclone/password" --field password } | complete)
                if $pass_result.exit_code == 0 {
                    $rclone_pass = ($pass_result.stdout | str trim)
                }
            }
            
            if ($rclone_pass | is-not-empty) {
                let rclone_env = { RCLONE_CONFIG_PASS: $rclone_pass }
                
                let config_result = (do { with-env $rclone_env { ^rclone config dump } } | complete)
                let current_config = if $config_result.exit_code == 0 and ($config_result.stdout | is-not-empty) {
                    $config_result.stdout | from json
                } else {
                    {}
                }
                
                let managed_remotes = ($current_config | transpose name config | where { |r| ($r.config.description? | default "") == "managed by pass-ssh-unpack" } | get name)
                
                mut deleted_count = 0
                for remote in $managed_remotes {
                    do { with-env $rclone_env { ^rclone config delete $remote } } | complete | ignore
                    $deleted_count = $deleted_count + 1
                }
                
                if $deleted_count > 0 {
                    log $"  Removed ($deleted_count) rclone remotes"
                    
                    # Re-add to chezmoi if managed
                    if (which chezmoi | is-not-empty) {
                        let managed_result = (do { chezmoi managed } | complete)
                        if $managed_result.exit_code == 0 and ($managed_result.stdout | str contains "rclone/rclone.conf") {
                            do { chezmoi re-add ~/.config/rclone/rclone.conf } | complete | ignore
                            log "  Synced rclone config to chezmoi"
                        }
                    }
                } else {
                    log "  No managed rclone remotes found"
                }
            } else {
                log "  (skipped rclone - could not get password)"
            }
        } else {
            log "  (rclone not installed)"
        }
        
        log "Done."
        return
    }
    
    log "Extracting SSH keys from Proton Pass..."
    log ""
    
    # =========================================================================
    # Setup
    # =========================================================================
    let current_hostname = (hostname | str trim | str downcase)
    let base_dir = ($env.HOME | path join ".ssh" "proton-pass")
    
    # Full mode: delete entire folder and start fresh
    if $full and ($base_dir | path exists) {
        log $"Full regeneration: clearing ($base_dir)..."
        rm -rf $base_dir
    }
    
    mkdir $base_dir
    
    let config_path = ($base_dir | path join "config")
    let config_header = "# =============================================================================
# DO NOT EDIT THIS FILE - IT IS AUTO-GENERATED BY pass-ssh-unpack
# =============================================================================
# Any manual changes will be lost on the next run.
#
# To use these keys, add the following to your ~/.ssh/config:
#     Include ~/.ssh/proton-pass/config
#
# To regenerate: pass-ssh-unpack
# To regenerate fully: pass-ssh-unpack --full
# ============================================================================="

    # =========================================================================
    # Load existing config (for incremental updates)
    # =========================================================================
    # Store existing hosts as records: {host: string, block: string}
    mut existing_hosts: list<record<host: string, block: string>> = []
    
    if (not $full) and ($config_path | path exists) {
        let config_content = (open $config_path | lines)
        mut current_host = ""
        mut current_block = ""
        mut in_block = false
        
        for line in $config_content {
            # Skip header comments
            if ($line | str contains "DO NOT EDIT") or ($line | str contains "=====") or ($line | str contains "Include") or ($line | str contains "regenerate") or ($line | str contains "To use") {
                continue
            }
            
            if ($line | str starts-with "Host ") {
                # Save previous block if exists
                if ($current_host | is-not-empty) {
                    $existing_hosts = ($existing_hosts | append {host: $current_host, block: $current_block})
                }
                $current_host = ($line | str replace "Host " "")
                $current_block = $line
                $in_block = true
            } else if $in_block and ($line | is-not-empty) {
                $current_block = $"($current_block)\n($line)"
            }
        }
        
        # Save last block
        if ($current_host | is-not-empty) {
            $existing_hosts = ($existing_hosts | append {host: $current_host, block: $current_block})
        }
    }
    
    # =========================================================================
    # Get vaults to process
    # =========================================================================
    let all_vaults = (pass-cli vault list --output json | from json | get vaults | get name)
    
    # Filter vaults with wildcard support
    mut vaults_to_process: list<string> = []
    
    if ($vault_filter | is-empty) {
        $vaults_to_process = $all_vaults
    } else {
        for pattern in $vault_filter {
            let regex_pattern = ($pattern | str replace -a '*' '.*' | str replace -a '?' '.')
            let matched_vaults = ($all_vaults | where { |v| $v =~ $regex_pattern })
            if ($matched_vaults | is-empty) {
                log $"Warning: No vaults matching '($pattern)' found"
            } else {
                for v in $matched_vaults {
                    if not ($v in $vaults_to_process) {
                        $vaults_to_process = ($vaults_to_process | append $v)
                    }
                }
            }
        }
    }
    
    # =========================================================================
    # Process vaults and extract keys
    # =========================================================================
    mut new_hosts: list<record<host: string, block: string>> = []
    mut processed_keys: list<string> = []
    mut rclone_entries: list<record<host: string, user: string, key_file: string, aliases: string>> = []
    
    for vault in $vaults_to_process {
        log $"[($vault)]"
        
        let keys_result = (do { pass-cli item list $vault --filter-type ssh-key --output json } | complete)
        
        if $keys_result.exit_code != 0 {
            log "  (no SSH keys)"
            log ""
            continue
        }
        
        let keys_json = ($keys_result.stdout | from json)
        let items = ($keys_json | get -o items | default [])
        
        if ($items | is-empty) {
            log "  (no SSH keys)"
            log ""
            continue
        }
        
        let vault_dir = ($base_dir | path join $vault)
        mkdir $vault_dir
        
        for item in $items {
            let title = ($item | get content.title)
            
            # Check if title matches patterns
            if not (matches-pattern $title $patterns) {
                continue
            }
            
            # Check machine-specific suffix
            if ($title | str contains "/") {
                let title_suffix = ($title | split row "/" | last | str downcase)
                if $title_suffix != $current_hostname {
                    log $"  Skipping: ($title) \(not for this machine\)"
                    continue
                }
            }
            
            log $"  Processing: ($title)"
            
            let private_key = ($item | get content.content.SshKey.private_key)
            let existing_pubkey = ($item | get -o content.content.SshKey.public_key | default "")
            
            # Get host from extra_fields
            let host_field = ($item | get content.extra_fields | where name == "Host" | get -o 0.content.Text | default "")
            let username_field = ($item | get content.extra_fields | where name == "Username" | get -o 0.content.Text | default "")
            let aliases_field = ($item | get content.extra_fields | where name == "Aliases" | get -o 0.content.Text | default "")
            
            if ($host_field | is-empty) {
                log "    -> skipped (no Host field)"
                continue
            }
            
            # Sanitize title for filename
            let safe_title = ($title | str replace -a "/" "-" | str replace -a " " "_")
            
            let privkey_path = ($vault_dir | path join $safe_title)
            let pubkey_path = ($vault_dir | path join $"($safe_title).pub")
            
            # Check if there's a private key
            mut has_key = false
            mut identity_path = ""
            
            if ($private_key | is-not-empty) and ($private_key != "null") {
                # Write private key
                $"($private_key)\n" | save -f $privkey_path
                chmod 600 $privkey_path
                
                # Track this key file
                $processed_keys = ($processed_keys | append $privkey_path)
                
                # Generate public key
                let keygen_result = (do { ssh-keygen -y -f $privkey_path } | complete)
                
                if $keygen_result.exit_code != 0 {
                    log "    -> failed to generate public key"
                    rm -f $privkey_path
                    continue
                }
                
                let generated_pubkey = ($keygen_result.stdout | str trim)
                $generated_pubkey | save -f $pubkey_path
                $has_key = true
                $identity_path = $"%d/.ssh/proton-pass/($vault)/($safe_title)"
                
                # Save public key back to Proton Pass if empty
                if ($existing_pubkey | is-empty) and ($generated_pubkey | is-not-empty) {
                    let update_result = (do { pass-cli item update --vault-name $vault --item-title $title --field $"public_key=($generated_pubkey)" } | complete)
                    if $update_result.exit_code == 0 {
                        log $"    -> ($safe_title) \(saved pubkey to Proton Pass\)"
                    } else {
                        log $"    -> ($safe_title) \(failed to save pubkey to Proton Pass\)"
                    }
                } else {
                    log $"    -> ($safe_title)"
                }
            } else {
                log $"    -> ($safe_title) \(no key, password auth\)"
            }
            
            # Build config entries (with or without key)
            mut config_block = $"Host ($host_field)"
            if $has_key {
                $config_block = $"($config_block)\n    IdentityFile \"($identity_path)\"\n    IdentitiesOnly yes"
            }
            if ($username_field | is-not-empty) {
                $config_block = $"($config_block)\n    User ($username_field)"
            }
            $new_hosts = ($new_hosts | append {host: $host_field, block: $config_block})
            
            # Alias entries
            let aliases_list = if ($aliases_field | is-not-empty) {
                $aliases_field | split row "," | each { |a| $a | str trim } | where { |a| $a | is-not-empty }
            } else {
                [$title]
            }
            
            for alias_entry in $aliases_list {
                if $alias_entry == $host_field {
                    continue
                }
                
                mut alias_block = $"# Alias of ($host_field)\nHost ($alias_entry)"
                if $has_key {
                    $alias_block = $"($alias_block)\n    IdentityFile \"($identity_path)\"\n    IdentitiesOnly yes"
                }
                if ($username_field | is-not-empty) {
                    $alias_block = $"($alias_block)\n    User ($username_field)"
                }
                $new_hosts = ($new_hosts | append {host: $alias_entry, block: $alias_block})
            }
            
            # Collect rclone entry data
            # remote_name = first alias (or title), other_aliases = remaining aliases
            let rclone_key_file = if $has_key {
                $"~/.ssh/proton-pass/($vault)/($safe_title)"
            } else {
                ""
            }
            
            # Parse aliases to get first as remote_name, rest as other_aliases
            let remote_name = if ($aliases_list | is-not-empty) {
                $aliases_list | first
            } else {
                $title
            }
            let other_aliases = if ($aliases_list | length) > 1 {
                $aliases_list | skip 1
            } else {
                []
            }
            let other_aliases_csv = ($other_aliases | str join ",")
            
            $rclone_entries = ($rclone_entries | append {
                remote_name: $remote_name,
                host: $host_field,
                user: $username_field,
                key_file: $rclone_key_file,
                other_aliases: $other_aliases_csv
            })
        }
        
        log ""
    }
    
    # =========================================================================
    # Merge configs and auto-prune
    # =========================================================================
    log "Generating SSH config..."
    
    # Start with existing hosts (if incremental mode)
    mut final_hosts: list<record<host: string, block: string>> = if $full {
        []
    } else {
        $existing_hosts
    }
    
    # Override/add new hosts (new hosts take precedence)
    for new_entry in $new_hosts {
        $final_hosts = ($final_hosts | where { |e| $e.host != $new_entry.host } | append $new_entry)
    }
    
    # Auto-prune: remove entries whose key files don't exist
    # (only prune entries that have an IdentityFile - password-only entries are kept)
    mut pruned_count = 0
    mut pruned_hosts: list<string> = []
    
    for entry in $final_hosts {
        let id_file_match = ($entry.block | parse -r 'IdentityFile "([^"]*)"' | get -o 0.capture0 | default "")
        let id_file = ($id_file_match | str replace "%d" $env.HOME)
        
        if ($id_file | is-not-empty) and (not ($id_file | path exists)) {
            $pruned_hosts = ($pruned_hosts | append $entry.host)
            $pruned_count = $pruned_count + 1
        }
    }
    
    $final_hosts = ($final_hosts | where { |e| not ($e.host in $pruned_hosts) })
    
    # =========================================================================
    # Write final config
    # =========================================================================
    $config_header | save -f $config_path
    
    # Sort hosts for consistent output
    let sorted_hosts = ($final_hosts | sort-by host)
    
    for entry in $sorted_hosts {
        $"\n($entry.block)" | save -a $config_path
    }
    
    # =========================================================================
    # Summary
    # =========================================================================
    let total_hosts = ($sorted_hosts | length)
    let total_aliases = ($sorted_hosts | where { |e| ($e.block | str contains "# Alias of") } | length)
    let primary_hosts = $total_hosts - $total_aliases
    
    log ""
    log $"Done! Generated config has ($primary_hosts) hosts and ($total_aliases) aliases."
    if $pruned_count > 0 {
        log $"Pruned ($pruned_count) orphaned entries."
    }
    log $"SSH config written to: ($config_path)"
    
    # =========================================================================
    # Sync rclone remotes
    # =========================================================================
    if not $no_rclone {
        sync-rclone-remotes $rclone_entries $full $quiet
    }
}

# Internal helper: Sync rclone SFTP remotes based on extracted SSH keys
def sync-rclone-remotes [
    entries: list<record<remote_name: string, host: string, user: string, key_file: string, other_aliases: string>>,
    full_mode: bool,
    quiet_mode: bool
] {
    # Helper for logging
    def rlog [msg: string] {
        if not $quiet_mode {
            print $msg
        }
    }
    
    # Skip if rclone not available
    if (which rclone | is-empty) {
        return
    }
    
    # Skip if no entries to process
    if ($entries | is-empty) {
        return
    }
    
    rlog ""
    rlog "Syncing rclone remotes..."
    
    # Get rclone password if not set
    mut rclone_pass = ($env.RCLONE_CONFIG_PASS? | default "")
    if ($rclone_pass | is-empty) {
        let pass_result = (do { pass-cli item view "pass://Personal/rclone/password" --field password } | complete)
        if $pass_result.exit_code != 0 {
            rlog "  (skipped - could not get rclone password)"
            return
        }
        $rclone_pass = ($pass_result.stdout | str trim)
    }
    
    # Set password for rclone commands
    let rclone_env = { RCLONE_CONFIG_PASS: $rclone_pass }
    
    # Get current config
    let config_result = (do { with-env $rclone_env { rclone config dump } } | complete)
    mut current_config = if $config_result.exit_code == 0 and ($config_result.stdout | is-not-empty) {
        $config_result.stdout | from json
    } else {
        {}
    }
    
    # Full mode: delete all managed remotes first
    if $full_mode {
        let managed_remotes = ($current_config | transpose name config | where { |r| ($r.config.description? | default "") == "managed by pass-ssh-unpack" } | get name)
        for remote in $managed_remotes {
            do { with-env $rclone_env { rclone config delete $remote } } | complete | ignore
        }
        # Refresh config after deletions
        let refresh_result = (do { with-env $rclone_env { rclone config dump } } | complete)
        $current_config = if $refresh_result.exit_code == 0 and ($refresh_result.stdout | is-not-empty) {
            $refresh_result.stdout | from json
        } else {
            {}
        }
    }
    
    mut created_count = 0
    mut skipped_count = 0
    
    # Process each entry
    for entry in $entries {
        let remote_name = $entry.remote_name
        let host = $entry.host
        let user = $entry.user
        let key_file = $entry.key_file
        let other_aliases = $entry.other_aliases
        
        if ($remote_name | is-empty) {
            continue
        }
        
        # Check if remote exists without our marker (unmanaged)
        let existing_remote = ($current_config | get -o $remote_name | default null)
        let existing_desc = if $existing_remote != null { $existing_remote.description? | default "" } else { "" }
        
        if $existing_remote != null and $existing_desc != "managed by pass-ssh-unpack" {
            rlog $"  Skipping ($remote_name): existing unmanaged remote"
            $skipped_count = $skipped_count + 1
            continue
        }
        
        # Create/update primary SFTP remote (named after first alias, connects to host)
        if ($key_file | is-not-empty) {
            do { with-env $rclone_env {
                ^rclone config create $remote_name sftp $"host=($host)" $"user=($user)" $"key_file=($key_file)" "description=managed by pass-ssh-unpack"
            } } | complete | ignore
        } else {
            do { with-env $rclone_env {
                ^rclone config create $remote_name sftp $"host=($host)" $"user=($user)" "ask_password=true" "description=managed by pass-ssh-unpack"
            } } | complete | ignore
        }
        $created_count = $created_count + 1
        
        # Create alias remotes for remaining aliases
        if ($other_aliases | is-not-empty) {
            let alias_list = ($other_aliases | split row "," | each { |a| $a | str trim } | where { |a| $a | is-not-empty })
            for alias_name in $alias_list {
                if $alias_name == $remote_name {
                    continue
                }
                
                # Check for unmanaged conflict
                let alias_remote = ($current_config | get -o $alias_name | default null)
                let alias_desc = if $alias_remote != null { $alias_remote.description? | default "" } else { "" }
                
                if $alias_remote != null and $alias_desc != "managed by pass-ssh-unpack" {
                    rlog $"  Skipping alias ($alias_name): existing unmanaged remote"
                    $skipped_count = $skipped_count + 1
                    continue
                }
                
                do { with-env $rclone_env {
                    ^rclone config create $alias_name alias $"remote=($remote_name):" "description=managed by pass-ssh-unpack"
                } } | complete | ignore
                $created_count = $created_count + 1
            }
        }
    }
    
    # Auto-prune: managed sftp remotes whose key_file doesn't exist
    let updated_result = (do { with-env $rclone_env { rclone config dump } } | complete)
    mut updated_config = if $updated_result.exit_code == 0 and ($updated_result.stdout | is-not-empty) {
        $updated_result.stdout | from json
    } else {
        {}
    }
    
    mut pruned_count = 0
    
    # Get managed sftp remotes and prune those with missing key files
    let sftp_remotes = ($updated_config | transpose name config | where { |r|
        ($r.config.type? | default "") == "sftp" and ($r.config.description? | default "") == "managed by pass-ssh-unpack"
    })
    
    for remote in $sftp_remotes {
        let key_path = ($remote.config.key_file? | default "")
        if ($key_path | is-not-empty) {
            let expanded_path = ($key_path | str replace "~" $env.HOME)
            if not ($expanded_path | path exists) {
                do { with-env $rclone_env { rclone config delete $remote.name } } | complete | ignore
                $pruned_count = $pruned_count + 1
            }
        }
    }
    
    # Prune alias remotes whose target was deleted
    let refresh_result2 = (do { with-env $rclone_env { rclone config dump } } | complete)
    $updated_config = if $refresh_result2.exit_code == 0 and ($refresh_result2.stdout | is-not-empty) {
        $refresh_result2.stdout | from json
    } else {
        {}
    }
    
    let alias_remotes = ($updated_config | transpose name config | where { |r|
        ($r.config.type? | default "") == "alias" and ($r.config.description? | default "") == "managed by pass-ssh-unpack"
    })
    
    for remote in $alias_remotes {
        let target = ($remote.config.remote? | default "")
        let target_name = ($target | str replace -r ':$' '')
        
        if not ($target_name in ($updated_config | columns)) {
            do { with-env $rclone_env { rclone config delete $remote.name } } | complete | ignore
            $pruned_count = $pruned_count + 1
        }
    }
    
    # Re-add to chezmoi if managed, then auto-commit/push
    if (which chezmoi | is-not-empty) {
        let managed_result = (do { chezmoi managed } | complete)
        if $managed_result.exit_code == 0 and ($managed_result.stdout | str contains "rclone/rclone.conf") {
            do { chezmoi re-add ~/.config/rclone/rclone.conf } | complete | ignore
            rlog $"  Synced ($created_count) remotes to chezmoi."
            
            # Auto-commit if there are changes
            let diff_result = (do { chezmoi git -- diff --quiet dot_config/rclone/private_rclone.conf } | complete)
            if $diff_result.exit_code != 0 {
                do { chezmoi git -- add dot_config/rclone/private_rclone.conf } | complete | ignore
                do { chezmoi git -- commit -m "chore: update rclone config via pass-ssh-unpack" } | complete | ignore
                
                # Auto-push if only 1 commit ahead
                let ahead_result = (do { chezmoi git -- rev-list --count "@{u}..HEAD" } | complete)
                let ahead_count = if $ahead_result.exit_code == 0 {
                    $ahead_result.stdout | str trim | into int
                } else {
                    0
                }
                
                if $ahead_count == 1 {
                    do { chezmoi git push } | complete | ignore
                    rlog "  Committed and pushed rclone config."
                } else {
                    rlog $"  Committed rclone config. Run 'chezmoi git push' to sync \(($ahead_count) commits ahead\)."
                }
            }
        } else {
            rlog $"  Synced ($created_count) remotes."
        }
    } else {
        rlog $"  Synced ($created_count) remotes."
    }
    
    if $skipped_count > 0 {
        rlog $"  Skipped ($skipped_count) \(unmanaged conflicts\)."
    }
    if $pruned_count > 0 {
        rlog $"  Pruned ($pruned_count) orphaned remotes."
    }
}

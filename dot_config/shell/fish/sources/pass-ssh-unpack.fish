# pass-ssh-unpack: Extract SSH keys from Proton Pass to local files
# See: docs/pass-ssh-unpack.md

function pass-ssh-unpack
    # =========================================================================
    # Argument parsing
    # =========================================================================
    set -l vault_names
    set -l item_patterns
    set -l full_mode false
    set -l quiet_mode false
    set -l skip_rclone false
    set -l purge_mode false
    
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case -v --vault
                set i (math $i + 1)
                set -a vault_names $argv[$i]
            case -i --item
                set i (math $i + 1)
                set -a item_patterns $argv[$i]
            case -f --full
                set full_mode true
            case -q --quiet
                set quiet_mode true
            case --no-rclone
                set skip_rclone true
            case --purge
                set purge_mode true
            case -h --help
                echo "Usage: pass-ssh-unpack [OPTIONS]"
                echo ""
                echo "Extract SSH keys from Proton Pass to local files and generate SSH config."
                echo ""
                echo "Options:"
                echo "  -v, --vault <PATTERN>      Vault(s) to process, supports * and ? wildcards"
                echo "  -i, --item <PATTERN>       Item title pattern(s) to unpack (repeatable)"
                echo "                             Supports * and ? wildcards"
                echo "  -f, --full                 Full regeneration (clear config first)"
                echo "  -q, --quiet                Suppress output"
                echo "  --no-rclone                Skip rclone remote sync"
                echo "  --purge                    Remove all managed SSH keys and rclone remotes, then exit"
                echo "  -h, --help                 Show this help message"
                echo ""
                echo "Examples:"
                echo "  pass-ssh-unpack                            # All vaults, all keys"
                echo "  pass-ssh-unpack -v Personal                # All keys from Personal vault"
                echo "  pass-ssh-unpack -v 'Dragon*'               # Vaults matching pattern"
                echo "  pass-ssh-unpack -i 'github/*'              # Keys matching pattern"
                echo "  pass-ssh-unpack -v Personal -i 'github/*'  # Combined filters"
                echo "  pass-ssh-unpack --full                     # Full regeneration"
                echo "  pass-ssh-unpack --no-rclone                # Skip rclone sync"
                echo "  pass-ssh-unpack --purge                    # Remove all managed data"
                return 0
            case '*'
                echo "Unknown option: $argv[$i]"
                echo "Use --help for usage information."
                return 1
        end
        set i (math $i + 1)
    end
    
    # Helper function for output
    function _log
        if test "$quiet_mode" != "true"
            echo $argv
        end
    end
    
    # =========================================================================
    # Dependency checks
    # =========================================================================
    if not command -q pass-cli
        echo "(pass-ssh-unpack) pass-cli not found. Install Proton Pass CLI first."
        return 1
    end
    
    if not pass-cli info &>/dev/null
        echo "(pass-ssh-unpack) Not logged into Proton Pass. Run 'pass-cli login' first."
        return 1
    end
    
    if not command -q ssh-keygen
        echo "(pass-ssh-unpack) ssh-keygen not found. Install OpenSSH first."
        return 1
    end
    
    if not command -q jq
        echo "(pass-ssh-unpack) jq not found. Install jq first."
        return 1
    end
    
    # =========================================================================
    # Purge mode: delete everything and exit
    # =========================================================================
    if test "$purge_mode" = "true"
        set -l base_dir "$HOME/.ssh/proton-pass"
        
        _log "Purging all managed SSH keys and rclone remotes..."
        
        # Delete SSH keys folder
        if test -d "$base_dir"
            rm -rf "$base_dir"
            _log "  Removed $base_dir"
        else
            _log "  $base_dir does not exist"
        end
        
        # Delete managed rclone remotes
        if command -q rclone
            if test -z "$RCLONE_CONFIG_PASS"
                set -gx RCLONE_CONFIG_PASS (pass-cli item view "pass://Personal/rclone/password" --field password 2>/dev/null)
            end
            
            if test -n "$RCLONE_CONFIG_PASS"
                set -l current_config (rclone config dump 2>/dev/null)
                if test -z "$current_config"
                    set current_config "{}"
                end
                
                set -l managed_remotes (echo "$current_config" | jq -r 'to_entries[] | select(.value.description == "managed by pass-ssh-unpack") | .key' 2>/dev/null)
                
                set -l deleted_count 0
                for remote in $managed_remotes
                    if test -n "$remote"
                        rclone config delete "$remote" &>/dev/null
                        set deleted_count (math $deleted_count + 1)
                    end
                end
                
                if test $deleted_count -gt 0
                    _log "  Removed $deleted_count rclone remotes"
                    
                    # Re-add to chezmoi if managed
                    if command -q chezmoi
                        if chezmoi managed 2>/dev/null | grep -q "rclone/rclone.conf"
                            chezmoi re-add ~/.config/rclone/rclone.conf &>/dev/null
                            _log "  Synced rclone config to chezmoi"
                        end
                    end
                else
                    _log "  No managed rclone remotes found"
                end
            else
                _log "  (skipped rclone - could not get password)"
            end
        else
            _log "  (rclone not installed)"
        end
        
        _log "Done."
        return 0
    end
    
    _log "Extracting SSH keys from Proton Pass..."
    _log ""
    
    # =========================================================================
    # Setup
    # =========================================================================
    set -l current_hostname (hostname | tr '[:upper:]' '[:lower:]')
    set -l base_dir "$HOME/.ssh/proton-pass"
    
    # Full mode: delete entire folder and start fresh
    if test "$full_mode" = "true"; and test -d "$base_dir"
        _log "Full regeneration: clearing $base_dir..."
        rm -rf "$base_dir"
    end
    
    mkdir -p "$base_dir"
    
    set -l config_path "$base_dir/config"
    set -l config_header "# =============================================================================
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
    # We'll store existing hosts in temp files: one file per host
    set -l existing_hosts_dir "$base_dir/.existing_hosts_tmp"
    rm -rf "$existing_hosts_dir"
    mkdir -p "$existing_hosts_dir"
    
    if test "$full_mode" != "true"; and test -f "$config_path"
        set -l current_host ""
        set -l current_block ""
        set -l in_block false
        
        while read -l line; or test -n "$line"
            # Skip header comments
            if string match -q "*DO NOT EDIT*" -- "$line"; or string match -q "*=====*" -- "$line"; or string match -q "*Include*" -- "$line"; or string match -q "*regenerate*" -- "$line"; or string match -q "*To use*" -- "$line"
                continue
            end
            
            if string match -qr "^Host (.+)\$" -- "$line"
                # Save previous block if exists
                if test -n "$current_host"
                    set -l safe_host (string replace -a '/' '_' -- "$current_host" | string replace -a ' ' '_')
                    echo "$current_block" > "$existing_hosts_dir/$safe_host"
                end
                set current_host (string replace "Host " "" -- "$line")
                set current_block "$line"
                set in_block true
            else if test "$in_block" = "true"; and test -n "$line"
                set current_block "$current_block
$line"
            end
        end < "$config_path"
        
        # Save last block
        if test -n "$current_host"
            set -l safe_host (string replace -a '/' '_' -- "$current_host" | string replace -a ' ' '_')
            echo "$current_block" > "$existing_hosts_dir/$safe_host"
        end
    end
    
    # =========================================================================
    # Get vaults to process
    # =========================================================================
    set -l all_vaults (pass-cli vault list --output json | jq -r '.vaults[].name')
    set -l vaults_to_process
    
    if test (count $vault_names) -eq 0
        # No vault filter - process all
        for v in $all_vaults
            test -n "$v"; and set -a vaults_to_process "$v"
        end
    else
        # Filter to specified vaults (with wildcard support)
        for pattern in $vault_names
            set -l matched false
            for v in $all_vaults
                test -z "$v"; and continue
                # Use fish glob matching
                if string match -q -- "$pattern" "$v"
                    set -a vaults_to_process "$v"
                    set matched true
                end
            end
            if test "$matched" = "false"
                _log "Warning: No vaults matching '$pattern' found"
            end
        end
    end
    
    # =========================================================================
    # Helper: Check if title matches any pattern
    # =========================================================================
    function _matches_pattern --inherit-variable item_patterns
        set -l title $argv[1]
        
        # If no patterns specified, match all
        if test (count $item_patterns) -eq 0
            return 0
        end
        
        for pattern in $item_patterns
            # Use fish glob matching with string match -w (wildcard)
            if string match -q -- "$pattern" "$title"
                return 0
            end
        end
        return 1
    end
    
    # =========================================================================
    # Process vaults and extract keys
    # =========================================================================
    set -l new_hosts_dir "$base_dir/.new_hosts_tmp"
    rm -rf "$new_hosts_dir"
    mkdir -p "$new_hosts_dir"
    
    set -l processed_keys_file "$base_dir/.processed_keys_tmp"
    rm -f "$processed_keys_file"
    
    set -l rclone_entries_file "$base_dir/.rclone_entries_tmp"
    rm -f "$rclone_entries_file"
    
    for vault in $vaults_to_process
        test -z "$vault"; and continue
        
        _log "[$vault]"
        
        set -l keys_json (pass-cli item list "$vault" --filter-type ssh-key --output json 2>/dev/null)
        
        if test -z "$keys_json"; or test "$keys_json" = "null"
            _log "  (no SSH keys)"
            _log ""
            continue
        end
        
        set -l item_count (echo "$keys_json" | jq '.items | length')
        
        if test "$item_count" = "0"; or test "$item_count" = "null"
            _log "  (no SSH keys)"
            _log ""
            continue
        end
        
        set -l vault_dir "$base_dir/$vault"
        mkdir -p "$vault_dir"
        
        for item in (echo "$keys_json" | jq -c '.items[]')
            set -l title (echo "$item" | jq -r '.content.title')
            
            # Check if title matches patterns
            if not _matches_pattern "$title"
                continue
            end
            
            # Check machine-specific suffix
            if string match -q "*/*" -- "$title"
                set -l title_suffix (echo "$title" | sed 's|.*/||' | tr '[:upper:]' '[:lower:]')
                if test "$title_suffix" != "$current_hostname"
                    _log "  Skipping: $title (not for this machine)"
                    continue
                end
            end
            
            _log "  Processing: $title"
            
            set -l private_key (echo "$item" | jq -r '.content.content.SshKey.private_key')
            set -l existing_pubkey (echo "$item" | jq -r '.content.content.SshKey.public_key // ""')
            set -l host_field (echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Host") | .content.Text' | head -1)
            set -l username_field (echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Username") | .content.Text' | head -1)
            set -l aliases_field (echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Aliases") | .content.Text' | head -1)
            
            if test -z "$host_field"; or test "$host_field" = "null"
                _log "    -> skipped (no Host field)"
                continue
            end
            
            set -l safe_title (echo "$title" | tr '/' '-' | tr ' ' '_')
            set -l privkey_path "$vault_dir/$safe_title"
            set -l pubkey_path "$vault_dir/$safe_title.pub"
            
            # Check if there's a private key
            set -l has_key false
            set -l identity_path ""
            
            if test -n "$private_key"; and test "$private_key" != "null"; and test "$private_key" != ""
                # Write private key
                echo "$private_key" > "$privkey_path"
                chmod 600 "$privkey_path"
                
                # Track this key file
                echo "$privkey_path" >> "$processed_keys_file"
                
                # Generate public key
                set -l generated_pubkey (ssh-keygen -y -f "$privkey_path" 2>/dev/null)
                
                if test -n "$generated_pubkey"
                    echo "$generated_pubkey" > "$pubkey_path"
                    set has_key true
                    set identity_path "%d/.ssh/proton-pass/$vault/$safe_title"
                    
                    # Save public key back to Proton Pass if empty
                    if test -z "$existing_pubkey"
                        if pass-cli item update --vault-name "$vault" --item-title "$title" --field "public_key=$generated_pubkey" &>/dev/null
                            _log "    -> $safe_title (saved pubkey to Proton Pass)"
                        else
                            _log "    -> $safe_title (failed to save pubkey to Proton Pass)"
                        end
                    else
                        _log "    -> $safe_title"
                    end
                else
                    _log "    -> $safe_title (failed to generate public key)"
                    rm -f "$privkey_path"
                end
            else
                _log "    -> $safe_title (no key, password auth)"
            end
            
            # Build config entries (with or without key)
            set -l config_block "Host $host_field"
            if test "$has_key" = "true"
                set config_block "$config_block
    IdentityFile \"$identity_path\"
    IdentitiesOnly yes"
            end
            if test -n "$username_field"; and test "$username_field" != "null"
                set config_block "$config_block
    User $username_field"
            end
            
            set -l safe_host (string replace -a '/' '_' -- "$host_field" | string replace -a ' ' '_')
            echo "$config_block" > "$new_hosts_dir/$safe_host"
            
            # Alias entries
            set -l aliases_list
            if test -n "$aliases_field"; and test "$aliases_field" != "null"
                set aliases_list (string split "," -- "$aliases_field" | string trim)
            else
                set aliases_list "$title"
            end
            
            for alias_entry in $aliases_list
                set alias_entry (string trim -- "$alias_entry")
                test -z "$alias_entry"; and continue
                test "$alias_entry" = "$host_field"; and continue
                
                set -l alias_block "# Alias of $host_field
Host $alias_entry"
                if test "$has_key" = "true"
                    set alias_block "$alias_block
    IdentityFile \"$identity_path\"
    IdentitiesOnly yes"
                end
                if test -n "$username_field"; and test "$username_field" != "null"
                    set alias_block "$alias_block
    User $username_field"
                end
                
                set -l safe_alias (string replace -a '/' '_' -- "$alias_entry" | string replace -a ' ' '_')
                echo "$alias_block" > "$new_hosts_dir/$safe_alias"
            end
            
            # Collect rclone entry data
            # Format: host|user|key_file|aliases (key_file uses ~ for home)
            set -l rclone_key_file ""
            if test "$has_key" = "true"
                set rclone_key_file "~/.ssh/proton-pass/$vault/$safe_title"
            end
            set -l aliases_csv (string join "," -- $aliases_list)
            echo "$host_field|$username_field|$rclone_key_file|$aliases_csv" >> "$rclone_entries_file"
        end
        
        _log ""
    end
    
    # =========================================================================
    # Merge configs and auto-prune
    # =========================================================================
    _log "Generating SSH config..."
    
    # Merge: new hosts override existing, keep existing if not touched
    set -l final_hosts_dir "$base_dir/.final_hosts_tmp"
    rm -rf "$final_hosts_dir"
    mkdir -p "$final_hosts_dir"
    
    # Start with existing hosts (if incremental mode)
    if test "$full_mode" != "true"
        for f in $existing_hosts_dir/*
            test -f "$f"; and cp "$f" "$final_hosts_dir/"
        end
    end
    
    # Override/add new hosts
    for f in $new_hosts_dir/*
        test -f "$f"; and cp "$f" "$final_hosts_dir/"
    end
    
    # Auto-prune: remove entries whose key files don't exist
    # (only prune entries that have an IdentityFile - password-only entries are kept)
    set -l pruned_count 0
    for f in $final_hosts_dir/*
        test -f "$f"; or continue
        
        set -l block (cat "$f")
        set -l id_file (echo "$block" | grep -o 'IdentityFile "[^"]*"' | sed 's/IdentityFile "//;s/"$//' | sed "s|%d|$HOME|")
        
        if test -n "$id_file"; and not test -f "$id_file"
            rm -f "$f"
            set pruned_count (math $pruned_count + 1)
        end
    end
    
    # Clean up temp files
    rm -f "$processed_keys_file"
    rm -rf "$existing_hosts_dir" "$new_hosts_dir"
    
    # =========================================================================
    # Write final config
    # =========================================================================
    echo "$config_header" > "$config_path"
    
    # Count totals
    set -l total_hosts 0
    set -l total_aliases 0
    
    # Sort hosts for consistent output
    for f in (ls "$final_hosts_dir" 2>/dev/null | sort)
        test -f "$final_hosts_dir/$f"; or continue
        
        set -l block (cat "$final_hosts_dir/$f")
        echo "" >> "$config_path"
        echo "$block" >> "$config_path"
        
        set total_hosts (math $total_hosts + 1)
        if string match -q "*# Alias of*" -- "$block"
            set total_aliases (math $total_aliases + 1)
        end
    end
    
    rm -rf "$final_hosts_dir"
    
    # =========================================================================
    # Summary
    # =========================================================================
    set -l primary_hosts (math $total_hosts - $total_aliases)
    
    _log ""
    _log "Done! Generated config has $primary_hosts hosts and $total_aliases aliases."
    if test $pruned_count -gt 0
        _log "Pruned $pruned_count orphaned entries."
    end
    _log "SSH config written to: $config_path"
    
    # =========================================================================
    # Sync rclone remotes
    # =========================================================================
    if test "$skip_rclone" != "true"
        _sync_rclone_remotes $full_mode $quiet_mode
    end
    
    # Clean up helper function
    functions -e _log
    functions -e _matches_pattern
end

# Internal helper: Sync rclone SFTP remotes based on extracted SSH keys
function _sync_rclone_remotes
    set -l full_mode $argv[1]
    set -l quiet_mode $argv[2]
    set -l base_dir "$HOME/.ssh/proton-pass"
    set -l rclone_entries_file "$base_dir/.rclone_entries_tmp"
    
    # Helper for logging
    function _rlog
        if test "$quiet_mode" != "true"
            echo $argv
        end
    end
    
    # Skip if rclone not available
    if not command -q rclone
        rm -f "$rclone_entries_file"
        functions -e _rlog
        return 0
    end
    
    # Skip if no entries to process
    if not test -f "$rclone_entries_file"
        functions -e _rlog
        return 0
    end
    
    _rlog ""
    _rlog "Syncing rclone remotes..."
    
    # Get rclone password if not set
    if test -z "$RCLONE_CONFIG_PASS"
        set -gx RCLONE_CONFIG_PASS (pass-cli item view "pass://Personal/rclone/password" --field password 2>/dev/null)
        if test -z "$RCLONE_CONFIG_PASS"
            _rlog "  (skipped - could not get rclone password)"
            rm -f "$rclone_entries_file"
            functions -e _rlog
            return 0
        end
    end
    
    # Get current config
    set -l current_config (rclone config dump 2>/dev/null)
    if test -z "$current_config"
        set current_config "{}"
    end
    
    # Full mode: delete all managed remotes first
    if test "$full_mode" = "true"
        set -l managed_remotes (echo "$current_config" | jq -r 'to_entries[] | select(.value.description == "managed by pass-ssh-unpack") | .key' 2>/dev/null)
        for remote in $managed_remotes
            test -z "$remote"; and continue
            rclone config delete "$remote" &>/dev/null
        end
        # Refresh config after deletions
        set current_config (rclone config dump 2>/dev/null)
        test -z "$current_config"; and set current_config "{}"
    end
    
    set -l created_count 0
    set -l skipped_count 0
    
    # Process each entry
    while read -l line
        set -l parts (string split "|" -- "$line")
        set -l host $parts[1]
        set -l user $parts[2]
        set -l key_file $parts[3]
        set -l aliases $parts[4]
        
        test -z "$host"; and continue
        
        # Check if remote exists without our marker (unmanaged)
        set -l existing_desc (echo "$current_config" | jq -r --arg name "$host" '.[$name].description // ""' 2>/dev/null)
        set -l existing_remote (echo "$current_config" | jq -r --arg name "$host" '.[$name] // empty' 2>/dev/null)
        
        if test -n "$existing_remote"; and test "$existing_desc" != "managed by pass-ssh-unpack"
            _rlog "  Skipping $host: existing unmanaged remote"
            set skipped_count (math $skipped_count + 1)
            continue
        end
        
        # Create/update primary SFTP remote
        if test -n "$key_file"
            rclone config create "$host" sftp \
                host="$host" \
                user="$user" \
                key_file="$key_file" \
                description="managed by pass-ssh-unpack" &>/dev/null
        else
            rclone config create "$host" sftp \
                host="$host" \
                user="$user" \
                ask_password=true \
                description="managed by pass-ssh-unpack" &>/dev/null
        end
        set created_count (math $created_count + 1)
        
        # Create alias remotes
        if test -n "$aliases"
            for alias_name in (string split "," -- "$aliases")
                set alias_name (string trim -- "$alias_name")
                test -z "$alias_name"; and continue
                test "$alias_name" = "$host"; and continue
                
                # Check for unmanaged conflict
                set existing_desc (echo "$current_config" | jq -r --arg name "$alias_name" '.[$name].description // ""' 2>/dev/null)
                set existing_remote (echo "$current_config" | jq -r --arg name "$alias_name" '.[$name] // empty' 2>/dev/null)
                
                if test -n "$existing_remote"; and test "$existing_desc" != "managed by pass-ssh-unpack"
                    _rlog "  Skipping alias $alias_name: existing unmanaged remote"
                    set skipped_count (math $skipped_count + 1)
                    continue
                end
                
                rclone config create "$alias_name" alias \
                    remote="$host:" \
                    description="managed by pass-ssh-unpack" &>/dev/null
                set created_count (math $created_count + 1)
            end
        end
    end < "$rclone_entries_file"
    
    rm -f "$rclone_entries_file"
    
    # Auto-prune: managed sftp remotes whose key_file doesn't exist
    set -l updated_config (rclone config dump 2>/dev/null)
    test -z "$updated_config"; and set updated_config "{}"
    
    set -l pruned_count 0
    
    # Get managed sftp remotes
    set -l sftp_remotes (echo "$updated_config" | jq -r 'to_entries[] | select(.value.type == "sftp" and .value.description == "managed by pass-ssh-unpack") | "\(.key)|\(.value.key_file // "")"' 2>/dev/null)
    
    for line in $sftp_remotes
        set -l parts (string split "|" -- "$line")
        set -l remote_name $parts[1]
        set -l key_path $parts[2]
        
        test -z "$remote_name"; and continue
        
        # Expand ~ to $HOME for file check
        set -l expanded_path (string replace "~" "$HOME" -- "$key_path")
        
        if test -n "$key_path"; and not test -f "$expanded_path"
            rclone config delete "$remote_name" &>/dev/null
            set pruned_count (math $pruned_count + 1)
        end
    end
    
    # Prune alias remotes whose target was deleted
    set updated_config (rclone config dump 2>/dev/null)
    test -z "$updated_config"; and set updated_config "{}"
    
    set -l alias_remotes (echo "$updated_config" | jq -r 'to_entries[] | select(.value.type == "alias" and .value.description == "managed by pass-ssh-unpack") | "\(.key)|\(.value.remote)"' 2>/dev/null)
    
    for line in $alias_remotes
        set -l parts (string split "|" -- "$line")
        set -l remote_name $parts[1]
        set -l target $parts[2]
        
        test -z "$remote_name"; and continue
        set -l target_name (string replace -r ':$' '' -- "$target")
        
        # Check if target exists in current config
        if not echo "$updated_config" | jq -e --arg name "$target_name" '.[$name]' &>/dev/null
            rclone config delete "$remote_name" &>/dev/null
            set pruned_count (math $pruned_count + 1)
        end
    end
    
    # Re-add to chezmoi if managed
    if command -q chezmoi
        if chezmoi managed 2>/dev/null | grep -q "rclone/rclone.conf"
            chezmoi re-add ~/.config/rclone/rclone.conf &>/dev/null
            _rlog "  Synced $created_count remotes to chezmoi."
        else
            _rlog "  Synced $created_count remotes."
        end
    else
        _rlog "  Synced $created_count remotes."
    end
    
    if test $skipped_count -gt 0
        _rlog "  Skipped $skipped_count (unmanaged conflicts)."
    end
    if test $pruned_count -gt 0
        _rlog "  Pruned $pruned_count orphaned remotes."
    end
    
    functions -e _rlog
end

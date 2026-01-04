# pass-ssh-unpack: Extract SSH keys from Proton Pass to local files
# See: docs/pass-ssh-unpack.md

pass-ssh-unpack() {
    # =========================================================================
    # Argument parsing
    # =========================================================================
    local -a vault_names=()
    local -a item_patterns=()
    local full_mode=false
    local quiet_mode=false
    local skip_rclone=false
    local purge_mode=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--vault)
                vault_names+=("$2")
                shift 2
                ;;
            -i|--item)
                item_patterns+=("$2")
                shift 2
                ;;
            -f|--full)
                full_mode=true
                shift
                ;;
            -q|--quiet)
                quiet_mode=true
                shift
                ;;
            --no-rclone)
                skip_rclone=true
                shift
                ;;
            --purge)
                purge_mode=true
                shift
                ;;
            -h|--help)
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
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information."
                return 1
                ;;
        esac
    done
    
    # Helper function for output
    _log() {
        if [[ "$quiet_mode" != "true" ]]; then
            echo "$@"
        fi
    }
    
    # =========================================================================
    # Dependency checks
    # =========================================================================
    if ! command -v pass-cli &>/dev/null; then
        echo "(pass-ssh-unpack) pass-cli not found. Install Proton Pass CLI first."
        return 1
    fi
    
    if ! pass-cli info &>/dev/null 2>&1; then
        echo "(pass-ssh-unpack) Not logged into Proton Pass. Run 'pass-cli login' first."
        return 1
    fi
    
    if ! command -v ssh-keygen &>/dev/null; then
        echo "(pass-ssh-unpack) ssh-keygen not found. Install OpenSSH first."
        return 1
    fi
    
    if ! command -v jq &>/dev/null; then
        echo "(pass-ssh-unpack) jq not found. Install jq first."
        return 1
    fi
    
    # =========================================================================
    # Purge mode: delete everything and exit
    # =========================================================================
    if [[ "$purge_mode" == "true" ]]; then
        local base_dir="$HOME/.ssh/proton-pass"
        
        _log "Purging all managed SSH keys and rclone remotes..."
        
        # Delete SSH keys folder
        if [[ -d "$base_dir" ]]; then
            rm -rf "$base_dir"
            _log "  Removed $base_dir"
        else
            _log "  $base_dir does not exist"
        fi
        
        # Delete managed rclone remotes
        if command -v rclone &>/dev/null; then
            if [[ -z "$RCLONE_CONFIG_PASS" ]]; then
                RCLONE_CONFIG_PASS=$(pass-cli item view "pass://Personal/rclone/password" --field password 2>/dev/null)
                if [[ -n "$RCLONE_CONFIG_PASS" ]]; then
                    export RCLONE_CONFIG_PASS
                fi
            fi
            
            if [[ -n "$RCLONE_CONFIG_PASS" ]]; then
                local current_config
                current_config=$(rclone config dump 2>/dev/null)
                [[ -z "$current_config" ]] && current_config="{}"
                
                local managed_remotes
                managed_remotes=$(echo "$current_config" | jq -r 'to_entries[] | select(.value.description == "managed by pass-ssh-unpack") | .key' 2>/dev/null)
                
                local deleted_count=0
                while IFS= read -r remote; do
                    [[ -z "$remote" ]] && continue
                    rclone config delete "$remote" &>/dev/null
                    ((deleted_count++))
                done <<< "$managed_remotes"
                
                if [[ $deleted_count -gt 0 ]]; then
                    _log "  Removed $deleted_count rclone remotes"
                    
                    # Re-add to chezmoi if managed
                    if command -v chezmoi &>/dev/null; then
                        if chezmoi managed 2>/dev/null | grep -q "rclone/rclone.conf"; then
                            chezmoi re-add ~/.config/rclone/rclone.conf &>/dev/null
                            _log "  Synced rclone config to chezmoi"
                        fi
                    fi
                else
                    _log "  No managed rclone remotes found"
                fi
            else
                _log "  (skipped rclone - could not get password)"
            fi
        else
            _log "  (rclone not installed)"
        fi
        
        _log "Done."
        return 0
    fi
    
    _log "Extracting SSH keys from Proton Pass..."
    _log ""
    
    # =========================================================================
    # Setup
    # =========================================================================
    local current_hostname
    current_hostname=$(hostname | tr '[:upper:]' '[:lower:]')
    
    local base_dir="$HOME/.ssh/proton-pass"
    
    # Full mode: delete entire folder and start fresh
    if [[ "$full_mode" == "true" ]] && [[ -d "$base_dir" ]]; then
        _log "Full regeneration: clearing $base_dir..."
        rm -rf "$base_dir"
    fi
    
    mkdir -p "$base_dir"
    
    local config_path="$base_dir/config"
    local config_header="# =============================================================================
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
    declare -A existing_hosts  # host -> full config block
    
    if [[ "$full_mode" != "true" ]] && [[ -f "$config_path" ]]; then
        local current_host=""
        local current_block=""
        local in_block=false
        
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip header comments
            if [[ "$line" =~ ^#.*DO\ NOT\ EDIT ]] || [[ "$line" =~ ^#.*=====.* ]] || [[ "$line" =~ ^#.*Include ]] || [[ "$line" =~ ^#.*regenerate ]] || [[ "$line" =~ ^#.*To\ use ]]; then
                continue
            fi
            
            if [[ "$line" =~ ^Host\ (.+)$ ]]; then
                # Save previous block if exists
                if [[ -n "$current_host" ]]; then
                    existing_hosts["$current_host"]="$current_block"
                fi
                current_host="${BASH_REMATCH[1]}"
                current_block="$line"
                in_block=true
            elif [[ "$in_block" == "true" ]] && [[ -n "$line" ]]; then
                current_block="$current_block"$'\n'"$line"
            fi
        done < "$config_path"
        
        # Save last block
        if [[ -n "$current_host" ]]; then
            existing_hosts["$current_host"]="$current_block"
        fi
    fi
    
    # =========================================================================
    # Get vaults to process
    # =========================================================================
    local -a vaults_to_process=()
    local all_vaults
    all_vaults=$(pass-cli vault list --output json | jq -r '.vaults[].name')
    
    if [[ ${#vault_names[@]} -eq 0 ]]; then
        # No vault filter - process all
        while IFS= read -r v; do
            [[ -n "$v" ]] && vaults_to_process+=("$v")
        done <<< "$all_vaults"
    else
        # Filter to specified vaults (with wildcard support)
        for pattern in "${vault_names[@]}"; do
            local matched=false
            while IFS= read -r v; do
                [[ -z "$v" ]] && continue
                # Use bash glob matching
                if [[ "$v" == $pattern ]]; then
                    vaults_to_process+=("$v")
                    matched=true
                fi
            done <<< "$all_vaults"
            if [[ "$matched" == "false" ]]; then
                _log "Warning: No vaults matching '$pattern' found"
            fi
        done
    fi
    
    # =========================================================================
    # Helper: Check if title matches any pattern
    # =========================================================================
    _matches_pattern() {
        local title="$1"
        
        # If no patterns specified, match all
        if [[ ${#item_patterns[@]} -eq 0 ]]; then
            return 0
        fi
        
        for pattern in "${item_patterns[@]}"; do
            # Use bash glob matching
            if [[ "$title" == $pattern ]]; then
                return 0
            fi
        done
        return 1
    }
    
    # =========================================================================
    # Process vaults and extract keys
    # =========================================================================
    # Clean up any leftover temp files
    rm -f "$base_dir/.new_hosts_tmp" "$base_dir/.processed_keys_tmp" "$base_dir/.rclone_entries_tmp"
    
    for vault in "${vaults_to_process[@]}"; do
        [[ -z "$vault" ]] && continue
        
        _log "[$vault]"
        
        local keys_json
        keys_json=$(pass-cli item list "$vault" --filter-type ssh-key --output json 2>/dev/null)
        
        if [[ -z "$keys_json" ]] || [[ "$keys_json" == "null" ]]; then
            _log "  (no SSH keys)"
            _log ""
            continue
        fi
        
        local item_count
        item_count=$(echo "$keys_json" | jq '.items | length')
        
        if [[ "$item_count" == "0" ]] || [[ "$item_count" == "null" ]]; then
            _log "  (no SSH keys)"
            _log ""
            continue
        fi
        
        local vault_dir="$base_dir/$vault"
        mkdir -p "$vault_dir"
        
        echo "$keys_json" | jq -c '.items[]' | while IFS= read -r item; do
            local title private_key existing_pubkey host_field username_field aliases_field safe_title privkey_path pubkey_path generated_pubkey
            
            title=$(echo "$item" | jq -r '.content.title')
            
            # Check if title matches patterns
            if ! _matches_pattern "$title"; then
                continue
            fi
            
            # Check machine-specific suffix
            if [[ "$title" == */* ]]; then
                local title_suffix
                title_suffix=$(echo "$title" | sed 's|.*/||' | tr '[:upper:]' '[:lower:]')
                if [[ "$title_suffix" != "$current_hostname" ]]; then
                    _log "  Skipping: $title (not for this machine)"
                    continue
                fi
            fi
            
            _log "  Processing: $title"
            
            private_key=$(echo "$item" | jq -r '.content.content.SshKey.private_key')
            existing_pubkey=$(echo "$item" | jq -r '.content.content.SshKey.public_key // ""')
            host_field=$(echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Host") | .content.Text' | head -1)
            username_field=$(echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Username") | .content.Text' | head -1)
            aliases_field=$(echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Aliases") | .content.Text' | head -1)
            
            if [[ -z "$host_field" ]] || [[ "$host_field" == "null" ]]; then
                _log "    -> skipped (no Host field)"
                continue
            fi
            
            safe_title=$(echo "$title" | tr '/' '-' | tr ' ' '_')
            privkey_path="$vault_dir/$safe_title"
            pubkey_path="$vault_dir/$safe_title.pub"
            
            # Check if there's a private key
            local has_key=false
            local identity_path=""
            
            if [[ -n "$private_key" ]] && [[ "$private_key" != "null" ]] && [[ "$private_key" != "" ]]; then
                # Write private key
                echo "$private_key" > "$privkey_path"
                chmod 600 "$privkey_path"
                
                # Track this key file
                echo "$privkey_path" >> "$base_dir/.processed_keys_tmp"
                
                # Generate public key
                generated_pubkey=$(ssh-keygen -y -f "$privkey_path" 2>/dev/null)
                
                if [[ -n "$generated_pubkey" ]]; then
                    echo "$generated_pubkey" > "$pubkey_path"
                    has_key=true
                    identity_path="%d/.ssh/proton-pass/$vault/$safe_title"
                    
                    # Save public key back to Proton Pass if empty
                    if [[ -z "$existing_pubkey" ]]; then
                        if pass-cli item update --vault-name "$vault" --item-title "$title" --field "public_key=$generated_pubkey" &>/dev/null; then
                            _log "    -> $safe_title (saved pubkey to Proton Pass)"
                        else
                            _log "    -> $safe_title (failed to save pubkey to Proton Pass)"
                        fi
                    else
                        _log "    -> $safe_title"
                    fi
                else
                    _log "    -> $safe_title (failed to generate public key)"
                    rm -f "$privkey_path"
                fi
            else
                _log "    -> $safe_title (no key, password auth)"
            fi
            
            # Build config entries (with or without key)
            local config_block="Host $host_field"
            if [[ "$has_key" == "true" ]]; then
                config_block="$config_block"$'\n'"    IdentityFile \"$identity_path\""$'\n'"    IdentitiesOnly yes"
            fi
            if [[ -n "$username_field" ]] && [[ "$username_field" != "null" ]]; then
                config_block="$config_block"$'\n'"    User $username_field"
            fi
            echo "$host_field|$config_block" >> "$base_dir/.new_hosts_tmp"
            
            # Alias entries
            local aliases_list=""
            if [[ -n "$aliases_field" ]] && [[ "$aliases_field" != "null" ]]; then
                aliases_list="$aliases_field"
            else
                aliases_list="$title"
            fi
            
            IFS=',' read -ra alias_array <<< "$aliases_list"
            for alias_entry in "${alias_array[@]}"; do
                alias_entry=$(echo "$alias_entry" | xargs)
                [[ -z "$alias_entry" ]] && continue
                [[ "$alias_entry" == "$host_field" ]] && continue
                
                local alias_block="# Alias of $host_field"$'\n'"Host $alias_entry"
                if [[ "$has_key" == "true" ]]; then
                    alias_block="$alias_block"$'\n'"    IdentityFile \"$identity_path\""$'\n'"    IdentitiesOnly yes"
                fi
                if [[ -n "$username_field" ]] && [[ "$username_field" != "null" ]]; then
                    alias_block="$alias_block"$'\n'"    User $username_field"
                fi
                echo "$alias_entry|$alias_block" >> "$base_dir/.new_hosts_tmp"
            done
            
            # Collect rclone entry data
            # Format: remote_name|host|user|key_file|other_aliases
            # remote_name = first alias (or title), other_aliases = remaining aliases
            local rclone_key_file=""
            if [[ "$has_key" == "true" ]]; then
                rclone_key_file="~/.ssh/proton-pass/$vault/$safe_title"
            fi
            
            # Parse aliases to get first as remote_name, rest as other_aliases
            IFS=',' read -ra rclone_alias_array <<< "$aliases_list"
            local remote_name=""
            local other_aliases=""
            for idx in "${!rclone_alias_array[@]}"; do
                local trimmed_alias
                trimmed_alias=$(echo "${rclone_alias_array[$idx]}" | xargs)
                [[ -z "$trimmed_alias" ]] && continue
                if [[ -z "$remote_name" ]]; then
                    remote_name="$trimmed_alias"
                else
                    if [[ -z "$other_aliases" ]]; then
                        other_aliases="$trimmed_alias"
                    else
                        other_aliases="$other_aliases,$trimmed_alias"
                    fi
                fi
            done
            
            # Fallback to title if no aliases
            [[ -z "$remote_name" ]] && remote_name="$title"
            
            echo "$remote_name|$host_field|${username_field:-}|${rclone_key_file}|${other_aliases}" >> "$base_dir/.rclone_entries_tmp"
        done
        
        _log ""
    done
    
    # =========================================================================
    # Merge configs and auto-prune
    # =========================================================================
    _log "Generating SSH config..."
    
    # Read new hosts from temp file
    declare -A new_hosts
    if [[ -f "$base_dir/.new_hosts_tmp" ]]; then
        while IFS='|' read -r host block; do
            new_hosts["$host"]="$block"
        done < "$base_dir/.new_hosts_tmp"
        rm -f "$base_dir/.new_hosts_tmp"
    fi
    
    # Merge: new hosts override existing, keep existing if not touched
    declare -A final_hosts
    
    # Start with existing hosts (if incremental mode)
    if [[ "$full_mode" != "true" ]]; then
        for host in "${!existing_hosts[@]}"; do
            final_hosts["$host"]="${existing_hosts[$host]}"
        done
    fi
    
    # Override/add new hosts
    for host in "${!new_hosts[@]}"; do
        final_hosts["$host"]="${new_hosts[$host]}"
    done
    
    # Auto-prune: remove entries whose key files don't exist
    local -a hosts_to_remove=()
    for host in "${!final_hosts[@]}"; do
        local block="${final_hosts[$host]}"
        # Extract IdentityFile path from block
        local id_file
        id_file=$(echo "$block" | grep -o 'IdentityFile "[^"]*"' | sed 's/IdentityFile "//;s/"$//' | sed "s|%d|$HOME|")
        
        if [[ -n "$id_file" ]] && [[ ! -f "$id_file" ]]; then
            hosts_to_remove+=("$host")
        fi
    done
    
    for host in "${hosts_to_remove[@]}"; do
        unset 'final_hosts[$host]'
    done
    
    # Clean up temp files
    rm -f "$base_dir/.processed_keys_tmp"
    
    # =========================================================================
    # Write final config
    # =========================================================================
    echo "$config_header" > "$config_path"
    
    # Sort hosts for consistent output
    local -a sorted_hosts
    IFS=$'\n' sorted_hosts=($(printf '%s\n' "${!final_hosts[@]}" | sort))
    
    for host in "${sorted_hosts[@]}"; do
        echo "" >> "$config_path"
        echo "${final_hosts[$host]}" >> "$config_path"
    done
    
    # =========================================================================
    # Summary
    # =========================================================================
    local total_hosts=${#final_hosts[@]}
    local total_aliases=0
    
    for host in "${!final_hosts[@]}"; do
        if [[ "${final_hosts[$host]}" == *"# Alias of"* ]]; then
            ((total_aliases++))
        fi
    done
    
    local primary_hosts=$((total_hosts - total_aliases))
    local pruned_count=${#hosts_to_remove[@]}
    
    _log ""
    _log "Done! Generated config has $primary_hosts hosts and $total_aliases aliases."
    if [[ $pruned_count -gt 0 ]]; then
        _log "Pruned $pruned_count orphaned entries."
    fi
    _log "SSH config written to: $config_path"
    
    # =========================================================================
    # Sync rclone remotes
    # =========================================================================
    if [[ "$skip_rclone" != "true" ]]; then
        _sync_rclone_remotes
    fi
}

# Internal helper: Sync rclone SFTP remotes based on extracted SSH keys
_sync_rclone_remotes() {
    local base_dir="$HOME/.ssh/proton-pass"
    local rclone_entries_file="$base_dir/.rclone_entries_tmp"
    
    # Skip if rclone not available
    if ! command -v rclone &>/dev/null; then
        rm -f "$rclone_entries_file"
        return 0
    fi
    
    # Skip if no entries to process
    if [[ ! -f "$rclone_entries_file" ]]; then
        return 0
    fi
    
    _log ""
    _log "Syncing rclone remotes..."
    
    # Get rclone password if not set
    if [[ -z "$RCLONE_CONFIG_PASS" ]]; then
        RCLONE_CONFIG_PASS=$(pass-cli item view "pass://Personal/rclone/password" --field password 2>/dev/null)
        if [[ -z "$RCLONE_CONFIG_PASS" ]]; then
            _log "  (skipped - could not get rclone password)"
            rm -f "$rclone_entries_file"
            return 0
        fi
        export RCLONE_CONFIG_PASS
    fi
    
    # Get current config
    local current_config
    current_config=$(rclone config dump 2>/dev/null)
    
    if [[ -z "$current_config" ]]; then
        current_config="{}"
    fi
    
    # Full mode: delete all managed remotes first
    if [[ "$full_mode" == "true" ]]; then
        local managed_remotes
        managed_remotes=$(echo "$current_config" | jq -r 'to_entries[] | select(.value.description == "managed by pass-ssh-unpack") | .key' 2>/dev/null)
        while IFS= read -r remote; do
            [[ -z "$remote" ]] && continue
            rclone config delete "$remote" &>/dev/null
        done <<< "$managed_remotes"
        # Refresh config after deletions
        current_config=$(rclone config dump 2>/dev/null)
        [[ -z "$current_config" ]] && current_config="{}"
    fi
    
    local created_count=0
    local skipped_count=0
    local -a created_primaries=()
    
    # Process each entry
    # Format: remote_name|host|user|key_file|other_aliases
    while IFS='|' read -r remote_name host user key_file other_aliases; do
        [[ -z "$remote_name" ]] && continue
        
        # Check if remote exists without our marker (unmanaged)
        local existing_desc
        existing_desc=$(echo "$current_config" | jq -r --arg name "$remote_name" '.[$name].description // ""' 2>/dev/null)
        local existing_remote
        existing_remote=$(echo "$current_config" | jq -r --arg name "$remote_name" '.[$name] // empty' 2>/dev/null)
        
        if [[ -n "$existing_remote" ]] && [[ "$existing_desc" != "managed by pass-ssh-unpack" ]]; then
            _log "  Skipping $remote_name: existing unmanaged remote"
            ((skipped_count++))
            continue
        fi
        
        # Create/update primary SFTP remote (named after first alias, connects to host)
        if [[ -n "$key_file" ]]; then
            rclone config create "$remote_name" sftp \
                host="$host" \
                user="$user" \
                key_file="$key_file" \
                description="managed by pass-ssh-unpack" &>/dev/null
        else
            rclone config create "$remote_name" sftp \
                host="$host" \
                user="$user" \
                ask_password=true \
                description="managed by pass-ssh-unpack" &>/dev/null
        fi
        ((created_count++))
        created_primaries+=("$remote_name")
        
        # Create alias remotes for remaining aliases
        IFS=',' read -ra alias_array <<< "$other_aliases"
        for alias_name in "${alias_array[@]}"; do
            alias_name=$(echo "$alias_name" | xargs)
            [[ -z "$alias_name" ]] && continue
            [[ "$alias_name" == "$remote_name" ]] && continue
            
            # Check for unmanaged conflict
            existing_desc=$(echo "$current_config" | jq -r --arg name "$alias_name" '.[$name].description // ""' 2>/dev/null)
            existing_remote=$(echo "$current_config" | jq -r --arg name "$alias_name" '.[$name] // empty' 2>/dev/null)
            
            if [[ -n "$existing_remote" ]] && [[ "$existing_desc" != "managed by pass-ssh-unpack" ]]; then
                _log "  Skipping alias $alias_name: existing unmanaged remote"
                ((skipped_count++))
                continue
            fi
            
            rclone config create "$alias_name" alias \
                remote="$remote_name:" \
                description="managed by pass-ssh-unpack" &>/dev/null
            ((created_count++))
        done
    done < "$rclone_entries_file"
    
    rm -f "$rclone_entries_file"
    
    # Auto-prune: managed sftp remotes whose key_file doesn't exist
    local updated_config
    updated_config=$(rclone config dump 2>/dev/null)
    [[ -z "$updated_config" ]] && updated_config="{}"
    
    local pruned_count=0
    local -a deleted_primaries=()
    
    # Get managed sftp remotes
    local sftp_remotes
    sftp_remotes=$(echo "$updated_config" | jq -r 'to_entries[] | select(.value.type == "sftp" and .value.description == "managed by pass-ssh-unpack") | "\(.key)|\(.value.key_file // "")"' 2>/dev/null)
    
    while IFS='|' read -r remote_name key_path; do
        [[ -z "$remote_name" ]] && continue
        
        # Expand ~ to $HOME for file check
        local expanded_path="${key_path/#\~/$HOME}"
        
        if [[ -n "$key_path" ]] && [[ ! -f "$expanded_path" ]]; then
            rclone config delete "$remote_name" &>/dev/null
            deleted_primaries+=("$remote_name")
            ((pruned_count++))
        fi
    done <<< "$sftp_remotes"
    
    # Prune alias remotes whose target was deleted
    updated_config=$(rclone config dump 2>/dev/null)
    [[ -z "$updated_config" ]] && updated_config="{}"
    
    local alias_remotes
    alias_remotes=$(echo "$updated_config" | jq -r 'to_entries[] | select(.value.type == "alias" and .value.description == "managed by pass-ssh-unpack") | "\(.key)|\(.value.remote)"' 2>/dev/null)
    
    while IFS='|' read -r remote_name target; do
        [[ -z "$remote_name" ]] && continue
        local target_name="${target%:}"  # Remove trailing colon
        
        # Check if target exists in current config
        if ! echo "$updated_config" | jq -e --arg name "$target_name" '.[$name]' &>/dev/null; then
            rclone config delete "$remote_name" &>/dev/null
            ((pruned_count++))
        fi
    done <<< "$alias_remotes"
    
    # Re-add to chezmoi if managed, then auto-commit/push
    if command -v chezmoi &>/dev/null; then
        if chezmoi managed 2>/dev/null | grep -q "rclone/rclone.conf"; then
            chezmoi re-add ~/.config/rclone/rclone.conf &>/dev/null
            _log "  Synced $created_count remotes to chezmoi."
            
            # Auto-commit if there are changes
            if chezmoi git -- diff --quiet dot_config/rclone/private_rclone.conf 2>/dev/null; then
                : # No changes to commit
            else
                chezmoi git -- add dot_config/rclone/private_rclone.conf &>/dev/null
                chezmoi git -- commit -m "chore: update rclone config via pass-ssh-unpack" &>/dev/null
                
                # Auto-push if only 1 commit ahead
                local ahead_count
                ahead_count=$(chezmoi git -- rev-list --count "@{u}..HEAD" 2>/dev/null || echo "0")
                if [[ "$ahead_count" == "1" ]]; then
                    chezmoi git push &>/dev/null
                    _log "  Committed and pushed rclone config."
                else
                    _log "  Committed rclone config. Run 'chezmoi git push' to sync ($ahead_count commits ahead)."
                fi
            fi
        else
            _log "  Synced $created_count remotes."
        fi
    else
        _log "  Synced $created_count remotes."
    fi
    
    if [[ $skipped_count -gt 0 ]]; then
        _log "  Skipped $skipped_count (unmanaged conflicts)."
    fi
    if [[ $pruned_count -gt 0 ]]; then
        _log "  Pruned $pruned_count orphaned remotes."
    fi
}

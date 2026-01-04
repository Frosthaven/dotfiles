# proton-unpack-ssh: Generate SSH public keys from Proton Pass
# - Extracts public keys from private keys stored in Proton Pass
# - Saves them to ~/.ssh/from-proton/<vault>/<keyname>.pub
# - Generates ~/.ssh/from-proton/config with IdentityFile mappings
# - Saves generated public keys back to Proton Pass if empty
# - Supports User and Aliases fields for complete SSH config generation

function proton-unpack-ssh
    # Check if pass-cli is available
    if not command -q pass-cli
        echo "(proton-unpack-ssh) pass-cli not found. Install Proton Pass CLI first."
        return 1
    end
    
    # Check if logged into Proton Pass
    if not pass-cli info &>/dev/null
        echo "(proton-unpack-ssh) Not logged into Proton Pass. Run 'pass-cli login' first."
        return 1
    end
    
    # Check if ssh-keygen is available
    if not command -q ssh-keygen
        echo "(proton-unpack-ssh) ssh-keygen not found. Install OpenSSH first."
        return 1
    end
    
    # Check if jq is available
    if not command -q jq
        echo "(proton-unpack-ssh) jq not found. Install jq first."
        return 1
    end
    
    echo "Generating SSH public keys from Proton Pass..."
    echo ""
    
    # Get hostname for duplicate key matching
    set -l current_hostname (hostname | tr '[:upper:]' '[:lower:]')
    
    # Create base directory
    set -l base_dir "$HOME/.ssh/from-proton"
    mkdir -p "$base_dir"
    
    # Initialize config file
    set -l config_path "$base_dir/config"
    echo "# Auto-generated from Proton Pass SSH keys" > "$config_path"
    echo "# Do not edit - regenerate with: proton-unpack-ssh" >> "$config_path"
    
    # Get all vaults
    set -l vaults (pass-cli vault list --output json | jq -r '.vaults[].name')
    
    # Temp file for tracking host -> keys
    set -l tmp_file "$base_dir/.host_keys_tmp"
    rm -f "$tmp_file"
    
    for vault in $vaults
        test -z "$vault"; and continue
        
        echo "[$vault]"
        
        # Get SSH keys in this vault
        set -l keys_json (pass-cli item list "$vault" --filter-type ssh-key --output json 2>/dev/null)
        
        if test -z "$keys_json"; or test "$keys_json" = "null"
            echo "  (no SSH keys)"
            echo ""
            continue
        end
        
        # Check if there are items
        set -l item_count (echo "$keys_json" | jq '.items | length')
        
        if test "$item_count" = "0"; or test "$item_count" = "null"
            echo "  (no SSH keys)"
            echo ""
            continue
        end
        
        # Create vault directory
        set -l vault_dir "$base_dir/$vault"
        mkdir -p "$vault_dir"
        
        # Process each key
        for item in (echo "$keys_json" | jq -c '.items[]')
            set -l title (echo "$item" | jq -r '.content.title')
            echo "  Processing: $title"
            
            set -l private_key (echo "$item" | jq -r '.content.content.SshKey.private_key')
            set -l existing_pubkey (echo "$item" | jq -r '.content.content.SshKey.public_key // ""')
            set -l host_field (echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Host") | .content.Text' | head -1)
            set -l username_field (echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Username") | .content.Text' | head -1)
            set -l aliases_field (echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Aliases") | .content.Text' | head -1)
            
            if test -z "$host_field"; or test "$host_field" = "null"
                echo "    -> skipped (no Host field)"
                continue
            end
            
            # Sanitize title for filename
            set -l safe_title (echo "$title" | tr '/' '-' | tr ' ' '_')
            
            # Generate public key
            set -l pubkey_path "$vault_dir/$safe_title.pub"
            set -l generated_pubkey (echo "$private_key" | ssh-keygen -y -f /dev/stdin 2>/dev/null)
            
            if test -n "$generated_pubkey"
                echo "$generated_pubkey" > "$pubkey_path"
                
                # Save public key back to Proton Pass if empty
                if test -z "$existing_pubkey"
                    if pass-cli item update --vault-name "$vault" --item-title "$title" --field "public_key=$generated_pubkey" &>/dev/null
                        echo "    -> $safe_title.pub (saved to Proton Pass)"
                    else
                        echo "    -> $safe_title.pub (failed to save to Proton Pass)"
                    end
                else
                    echo "    -> $safe_title.pub"
                end
                
                # Build list of hosts (main host + aliases)
                # If no Aliases field, use the item title as an alias
                set -l all_hosts $host_field
                if test -n "$aliases_field"; and test "$aliases_field" != "null"
                    # Split comma-separated aliases and append
                    for alias in (string split "," -- "$aliases_field" | string trim)
                        set -a all_hosts $alias
                    end
                else
                    # Use title as fallback alias
                    set -a all_hosts $title
                end
                
                # Track for duplicate handling
                # Format: host|title|pubkey_path|username
                for host in $all_hosts
                    test -z "$host"; and continue
                    echo "$host|$title|$pubkey_path|$username_field" >> "$tmp_file"
                end
            else
                echo "    -> failed to generate public key"
            end
        end
        
        echo ""
    end
    
    # Generate SSH config entries
    echo "Generating SSH config..."
    
    if test -f "$tmp_file"
        # Get unique hosts
        set -l hosts (cut -d'|' -f1 "$tmp_file" | sort -u)
        
        for host in $hosts
            test -z "$host"; and continue
            
            # Get all keys for this host
            set -l keys_for_host (grep "^$host|" "$tmp_file")
            
            # Count keys for this host
            set -l key_count (echo "$keys_for_host" | wc -l | tr -d ' ')
            
            set -l selected_line
            if test "$key_count" -gt 1
                # Try to find key matching hostname
                set -l matching (echo "$keys_for_host" | grep -i "$current_hostname" | head -1)
                
                if test -n "$matching"
                    set selected_line "$matching"
                else
                    # Fallback to first key
                    set selected_line (echo "$keys_for_host" | head -1)
                end
            else
                set selected_line "$keys_for_host"
            end
            
            set -l selected_path (echo "$selected_line" | cut -d'|' -f3)
            set -l selected_user (echo "$selected_line" | cut -d'|' -f4)
            
            # Append to config (quote path for spaces)
            echo "" >> "$config_path"
            echo "Host $host" >> "$config_path"
            echo "    IdentityFile \"$selected_path\"" >> "$config_path"
            echo "    IdentitiesOnly yes" >> "$config_path"
            if test -n "$selected_user"; and test "$selected_user" != "null"
                echo "    User $selected_user" >> "$config_path"
            end
        end
        
        # Cleanup temp file
        rm -f "$tmp_file"
    end
    
    set -l total_keys (grep -c "^Host " "$config_path" 2>/dev/null; or echo "0")
    
    echo ""
    echo "Done! Generated config for $total_keys hosts."
    echo "SSH config written to: $config_path"
end

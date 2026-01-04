# proton-unpack-ssh: Generate SSH public keys from Proton Pass
# - Extracts public keys from private keys stored in Proton Pass
# - Saves them to ~/.ssh/from-proton/<vault>/<keyname>.pub
# - Generates ~/.ssh/from-proton/config with IdentityFile mappings
# - Saves generated public keys back to Proton Pass if empty
# - Supports User and Aliases fields for complete SSH config generation

proton-unpack-ssh() {
    # Check if pass-cli is available
    if ! command -v pass-cli &>/dev/null; then
        echo "(proton-unpack-ssh) pass-cli not found. Install Proton Pass CLI first."
        return 1
    fi
    
    # Check if logged into Proton Pass
    if ! pass-cli info &>/dev/null 2>&1; then
        echo "(proton-unpack-ssh) Not logged into Proton Pass. Run 'pass-cli login' first."
        return 1
    fi
    
    # Check if ssh-keygen is available
    if ! command -v ssh-keygen &>/dev/null; then
        echo "(proton-unpack-ssh) ssh-keygen not found. Install OpenSSH first."
        return 1
    fi
    
    # Check if jq is available
    if ! command -v jq &>/dev/null; then
        echo "(proton-unpack-ssh) jq not found. Install jq first."
        return 1
    fi
    
    echo "Generating SSH public keys from Proton Pass..."
    echo ""
    
    # Get hostname for duplicate key matching
    local current_hostname
    current_hostname=$(hostname | tr '[:upper:]' '[:lower:]')
    
    # Create base directory
    local base_dir="$HOME/.ssh/from-proton"
    mkdir -p "$base_dir"
    
    # Initialize config file
    local config_path="$base_dir/config"
    echo "# Auto-generated from Proton Pass SSH keys" > "$config_path"
    echo "# Do not edit - regenerate with: proton-unpack-ssh" >> "$config_path"
    
    # Get all vaults
    local vaults
    vaults=$(pass-cli vault list --output json | jq -r '.vaults[].name')
    
    while IFS= read -r vault; do
        [ -z "$vault" ] && continue
        
        echo "[$vault]"
        
        # Get SSH keys in this vault
        local keys_json
        keys_json=$(pass-cli item list "$vault" --filter-type ssh-key --output json 2>/dev/null)
        
        if [ -z "$keys_json" ] || [ "$keys_json" = "null" ]; then
            echo "  (no SSH keys)"
            echo ""
            continue
        fi
        
        # Check if there are items
        local item_count
        item_count=$(echo "$keys_json" | jq '.items | length')
        
        if [ "$item_count" = "0" ] || [ "$item_count" = "null" ]; then
            echo "  (no SSH keys)"
            echo ""
            continue
        fi
        
        # Create vault directory
        local vault_dir="$base_dir/$vault"
        mkdir -p "$vault_dir"
        
        # Process each key
        echo "$keys_json" | jq -c '.items[]' | while IFS= read -r item; do
            local title private_key existing_pubkey host_field username_field aliases_field safe_title pubkey_path generated_pubkey
            
            title=$(echo "$item" | jq -r '.content.title')
            echo "  Processing: $title"
            
            private_key=$(echo "$item" | jq -r '.content.content.SshKey.private_key')
            existing_pubkey=$(echo "$item" | jq -r '.content.content.SshKey.public_key // ""')
            host_field=$(echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Host") | .content.Text' | head -1)
            username_field=$(echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Username") | .content.Text' | head -1)
            aliases_field=$(echo "$item" | jq -r '.content.extra_fields[] | select(.name == "Aliases") | .content.Text' | head -1)
            
            if [ -z "$host_field" ] || [ "$host_field" = "null" ]; then
                echo "    -> skipped (no Host field)"
                continue
            fi
            
            # Sanitize title for filename
            safe_title=$(echo "$title" | tr '/' '-' | tr ' ' '_')
            
            # Generate public key
            pubkey_path="$vault_dir/$safe_title.pub"
            
            generated_pubkey=$(echo "$private_key" | ssh-keygen -y -f /dev/stdin 2>/dev/null)
            
            if [ -n "$generated_pubkey" ]; then
                echo "$generated_pubkey" > "$pubkey_path"
                
                # Save public key back to Proton Pass if empty
                if [ -z "$existing_pubkey" ]; then
                    if pass-cli item update --vault-name "$vault" --item-title "$title" --field "public_key=$generated_pubkey" &>/dev/null; then
                        echo "    -> $safe_title.pub (saved to Proton Pass)"
                    else
                        echo "    -> $safe_title.pub (failed to save to Proton Pass)"
                    fi
                else
                    echo "    -> $safe_title.pub"
                fi
                
                # Track for duplicate handling (append to temp file since we're in subshell)
                # Format: host|title|pubkey_path|username|is_alias
                # Primary host entry (is_alias=0)
                echo "$host_field|$title|$pubkey_path|$username_field|0" >> "$base_dir/.host_keys_tmp"
                
                # Build list of aliases
                local aliases_list=""
                if [ -n "$aliases_field" ] && [ "$aliases_field" != "null" ]; then
                    aliases_list="$aliases_field"
                else
                    # Use title as fallback alias
                    aliases_list="$title"
                fi
                
                # Add alias entries (is_alias=1)
                IFS=',' read -ra alias_array <<< "$aliases_list"
                for alias_entry in "${alias_array[@]}"; do
                    alias_entry=$(echo "$alias_entry" | xargs)  # trim whitespace
                    [ -z "$alias_entry" ] && continue
                    # Skip if alias is same as host
                    [ "$alias_entry" = "$host_field" ] && continue
                    echo "$alias_entry|$title|$pubkey_path|$username_field|1" >> "$base_dir/.host_keys_tmp"
                done
            else
                echo "    -> failed to generate public key"
            fi
        done
        
        echo ""
    done <<< "$vaults"
    
    # Generate SSH config entries
    echo "Generating SSH config..."
    
    if [ -f "$base_dir/.host_keys_tmp" ]; then
        # Get unique hosts
        local hosts
        hosts=$(cut -d'|' -f1 "$base_dir/.host_keys_tmp" | sort -u)
        
        while IFS= read -r host; do
            [ -z "$host" ] && continue
            
            # Get all keys for this host
            local keys_for_host selected_line selected_path selected_user
            keys_for_host=$(grep "^$host|" "$base_dir/.host_keys_tmp")
            
            # Count keys for this host
            local key_count
            key_count=$(echo "$keys_for_host" | wc -l)
            
            if [ "$key_count" -gt 1 ]; then
                # Try to find key matching hostname
                local matching
                matching=$(echo "$keys_for_host" | grep -i "$current_hostname" | head -1)
                
                if [ -n "$matching" ]; then
                    selected_line="$matching"
                else
                    # Fallback to first key
                    selected_line=$(echo "$keys_for_host" | head -1)
                fi
            else
                selected_line="$keys_for_host"
            fi
            
            selected_path=$(echo "$selected_line" | cut -d'|' -f3)
            selected_user=$(echo "$selected_line" | cut -d'|' -f4)
            selected_is_alias=$(echo "$selected_line" | cut -d'|' -f5)
            
            # Append to config (quote path for spaces)
            echo "" >> "$config_path"
            if [ "$selected_is_alias" = "1" ]; then
                echo "# Alias" >> "$config_path"
            fi
            echo "Host $host" >> "$config_path"
            echo "    IdentityFile \"$selected_path\"" >> "$config_path"
            echo "    IdentitiesOnly yes" >> "$config_path"
            if [ -n "$selected_user" ] && [ "$selected_user" != "null" ]; then
                echo "    User $selected_user" >> "$config_path"
            fi
        done <<< "$hosts"
        
        # Cleanup temp file
        rm -f "$base_dir/.host_keys_tmp"
    fi
    
    local total_keys
    total_keys=$(grep -c "^Host " "$config_path" 2>/dev/null || echo "0")
    
    echo ""
    echo "Done! Generated config for $total_keys hosts."
    echo "SSH config written to: $config_path"
}

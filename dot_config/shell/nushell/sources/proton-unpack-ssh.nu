# proton-unpack-ssh: Generate SSH public keys from Proton Pass
# - Extracts public keys from private keys stored in Proton Pass
# - Saves them to ~/.ssh/from-proton/<vault>/<keyname>.pub
# - Generates ~/.ssh/from-proton/config with IdentityFile mappings
# - Saves generated public keys back to Proton Pass if empty
# - Supports User and Aliases fields for complete SSH config generation

def proton-unpack-ssh [] {
    # Check if pass-cli is available
    if (which pass-cli | is-empty) {
        print "(proton-unpack-ssh) pass-cli not found. Install Proton Pass CLI first."
        return
    }
    
    # Check if logged into Proton Pass
    let login_check = (do { pass-cli info } | complete)
    if $login_check.exit_code != 0 {
        print "(proton-unpack-ssh) Not logged into Proton Pass. Run 'pass-cli login' first."
        return
    }
    
    # Check if ssh-keygen is available
    if (which ssh-keygen | is-empty) {
        print "(proton-unpack-ssh) ssh-keygen not found. Install OpenSSH first."
        return
    }
    
    print "Generating SSH public keys from Proton Pass..."
    print ""
    
    # Get hostname for duplicate key matching
    let current_hostname = (hostname | str trim | str downcase)
    
    # Create base directory
    let base_dir = ($env.HOME | path join ".ssh" "from-proton")
    mkdir $base_dir
    
    # Initialize config file
    let config_path = ($base_dir | path join "config")
    "# Auto-generated from Proton Pass SSH keys\n# Do not edit - regenerate with: proton-unpack-ssh\n" | save -f $config_path
    
    # Get all vaults
    let vaults = (pass-cli vault list --output json | from json | get vaults | get name)
    
    # Track host -> key mappings for duplicate handling
    # Each entry: {host: string, title: string, path: string, user: string}
    mut host_keys: list<record<host: string, title: string, path: string, user: string>> = []
    
    for vault in $vaults {
        print $"[($vault)]"
        
        # Get SSH keys in this vault
        let keys_result = (do { pass-cli item list $vault --filter-type ssh-key --output json } | complete)
        
        if $keys_result.exit_code != 0 {
            print "  \(no SSH keys\)"
            print ""
            continue
        }
        
        let keys_json = ($keys_result.stdout | from json)
        let items = ($keys_json | get -o items | default [])
        
        if ($items | is-empty) {
            print "  \(no SSH keys\)"
            print ""
            continue
        }
        
        # Create vault directory
        let vault_dir = ($base_dir | path join $vault)
        mkdir $vault_dir
        
        for item in $items {
            let title = ($item | get content.title)
            print $"  Processing: ($title)"
            
            let private_key = ($item | get content.content.SshKey.private_key)
            let existing_pubkey = ($item | get -o content.content.SshKey.public_key | default "")
            
            # Get host from extra_fields
            let host_field = ($item | get content.extra_fields | where name == "Host" | first | get -o content.Text | default "")
            let username_field = ($item | get content.extra_fields | where name == "Username" | first | get -o content.Text | default "")
            let aliases_field = ($item | get content.extra_fields | where name == "Aliases" | first | get -o content.Text | default "")
            
            if ($host_field | is-empty) {
                print "    -> skipped \(no Host field\)"
                continue
            }
            
            # Sanitize title for filename
            let safe_title = ($title | str replace -a "/" "-" | str replace -a " " "_")
            
            # Generate public key using temp file (Nushell doesn't pipe raw data to /dev/stdin properly)
            let pubkey_path = ($vault_dir | path join $"($safe_title).pub")
            let temp_key_file = (mktemp)
            mut generated_pubkey = ""
            
            try {
                # Ensure trailing newline and proper permissions for ssh-keygen
                $"($private_key)\n" | save -f $temp_key_file
                chmod 600 $temp_key_file
                let keygen_result = (do { ssh-keygen -y -f $temp_key_file } | complete)
                rm -f $temp_key_file
                
                if $keygen_result.exit_code != 0 {
                    print "    -> failed to generate public key"
                    continue
                }
                
                $generated_pubkey = ($keygen_result.stdout | str trim)
                $generated_pubkey | save -f $pubkey_path
            } catch {
                rm -f $temp_key_file
                print "    -> failed to generate public key"
                continue
            }
            
            # Save public key back to Proton Pass if empty
            if ($existing_pubkey | is-empty) and ($generated_pubkey | is-not-empty) {
                let pubkey_to_save = $generated_pubkey
                let update_result = (do { pass-cli item update --vault-name $vault --item-title $title --field $"public_key=($pubkey_to_save)" } | complete)
                if $update_result.exit_code == 0 {
                    print $"    -> ($safe_title).pub \(saved to Proton Pass\)"
                } else {
                    print $"    -> ($safe_title).pub \(failed to save to Proton Pass\)"
                }
            } else {
                print $"    -> ($safe_title).pub"
            }
            
            # Build list of hosts (main host + aliases)
            # If no Aliases field, use the item title as an alias
            mut all_hosts = [$host_field]
            if ($aliases_field | is-not-empty) {
                let aliases = ($aliases_field | split row "," | each { |a| $a | str trim } | where { |a| $a | is-not-empty })
                $all_hosts = ($all_hosts | append $aliases)
            } else {
                # Use title as fallback alias
                $all_hosts = ($all_hosts | append $title)
            }
            
            # Track for duplicate handling
            for host in $all_hosts {
                $host_keys = ($host_keys | append {host: $host, title: $title, path: ($pubkey_path | into string), user: $username_field})
            }
        }
        
        print ""
    }
    
    # Generate SSH config entries
    print "Generating SSH config..."
    
    # Get unique hosts
    let unique_hosts = ($host_keys | get host | uniq)
    
    for host in $unique_hosts {
        let keys_for_host = ($host_keys | where host == $host)
        
        # If multiple keys for same host, pick one matching hostname
        let selected_key = if ($keys_for_host | length) > 1 {
            # Try to find a key with title matching current hostname
            let matching = ($keys_for_host | where { |k| ($k.title | str downcase) =~ $current_hostname })
            if ($matching | is-not-empty) {
                $matching | first
            } else {
                # Fallback to first key
                $keys_for_host | first
            }
        } else {
            $keys_for_host | first
        }
        
        # Build config entry (quote path for spaces)
        mut config_entry = $"\nHost ($host)\n    IdentityFile \"($selected_key.path)\"\n    IdentitiesOnly yes"
        if ($selected_key.user | is-not-empty) {
            $config_entry = $"($config_entry)\n    User ($selected_key.user)"
        }
        $config_entry = $"($config_entry)\n"
        
        $config_entry | save -a $config_path
    }
    
    let total_keys = ($unique_hosts | length)
    print ""
    print $"Done! Generated config for ($total_keys) hosts."
    print $"SSH config written to: ($config_path)"
}

# SSH Agent and Proton Pass Integration
# - Starts SSH agent (Linux/COSMIC)
# - Loads SSH keys from Proton Pass (only if not already loaded)

# Linux (Arch/COSMIC): Use systemd ssh-agent socket
if (which pacman | is-not-empty) and (($env.XDG_CURRENT_DESKTOP? | default "" | str downcase) == "cosmic") {
    $env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/ssh-agent.socket"
    
    # Auto-start service if not running
    let service_status = (systemctl --user is-active ssh-agent.service | complete)
    if $service_status.exit_code != 0 {
        systemctl --user start ssh-agent.service
    }
}

# Load SSH keys from Proton Pass (only if agent is empty)
if (which pass-cli | is-not-empty) {
    # Check if keys are already loaded in agent (fast check)
    let agent_check = (do { ssh-add -l } | complete)
    let keys_loaded = ($agent_check.exit_code == 0 and ($agent_check.stdout | str trim | is-not-empty))
    
    if $keys_loaded {
        # Keys already loaded, set env var for rclone.nu to skip login check
        $env.PROTON_PASS_LOGGED_IN = "true"
    } else {
        # No keys loaded, check if logged in to Proton Pass
        let login_check = (do { pass-cli info } | complete)
        if $login_check.exit_code == 0 {
            $env.PROTON_PASS_LOGGED_IN = "true"
            # Load keys from all vaults
            do { pass-cli ssh-agent load } | complete | ignore
        } else {
            $env.PROTON_PASS_LOGGED_IN = "false"
            print "(proton pass) Not logged in. Run 'pass-cli login' to load SSH keys."
        }
    }
}

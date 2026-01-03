# SSH Agent and Proton Pass Integration
# - Starts SSH agent (Linux/COSMIC)
# - Loads SSH keys from Proton Pass

# Linux (Arch/COSMIC): Use systemd ssh-agent socket
if (which pacman | is-not-empty) and (($env.XDG_CURRENT_DESKTOP? | default "" | str downcase) == "cosmic") {
    $env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/ssh-agent.socket"
    
    # Auto-start service if not running
    let service_status = (systemctl --user is-active ssh-agent.service | complete)
    if $service_status.exit_code != 0 {
        systemctl --user start ssh-agent.service
    }
}

# Load SSH keys from Proton Pass (all vaults)
if (which pass-cli | is-not-empty) {
    let login_check = (do { pass-cli info } | complete)
    if $login_check.exit_code == 0 {
        # Silently load keys from all vaults
        do { pass-cli ssh-agent load } | complete | ignore
    } else {
        print "(proton pass) Not logged in. Run 'pass-cli login' to load SSH keys."
    }
}

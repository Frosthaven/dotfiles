# SSH Agent Configuration
# - Starts SSH agent (Linux/COSMIC)

# Linux (Arch/COSMIC): Use systemd ssh-agent socket
if (which pacman | is-not-empty) and (($env.XDG_CURRENT_DESKTOP? | default "" | str downcase) == "cosmic") {
    $env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/ssh-agent.socket"
    
    # Auto-start service if not running
    let service_status = (systemctl --user is-active ssh-agent.service | complete)
    if $service_status.exit_code != 0 {
        systemctl --user start ssh-agent.service
    }
}

# Set PROTON_PASS_LOGGED_IN based on pass-cli status (for rclone.nu)
if (which pass-cli | is-not-empty) {
    let login_check = (do { pass-cli info } | complete)
    if $login_check.exit_code == 0 {
        $env.PROTON_PASS_LOGGED_IN = "true"
    } else {
        $env.PROTON_PASS_LOGGED_IN = "false"
    }
}

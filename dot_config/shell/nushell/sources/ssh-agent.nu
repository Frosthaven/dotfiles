# SSH Agent configuration for Arch-based distros with COSMIC desktop
if (which pacman | is-not-empty) and ($env.XDG_CURRENT_DESKTOP? == "COSMIC") {
    # Set SSH_AUTH_SOCK to systemd user service socket
    $env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/ssh-agent.socket"
    
    # Auto-start service if not running
    let service_status = (systemctl --user is-active ssh-agent.service | complete)
    if $service_status.exit_code != 0 {
        systemctl --user start ssh-agent.service
    }
}

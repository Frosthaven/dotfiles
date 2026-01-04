# Rclone Integration with Proton Pass
# - Lazy loads RCLONE_CONFIG_PASS on first rclone use
# - Provides rclone-config helper that syncs to chezmoi

# Wrapper: rclone with lazy password loading
def --env --wrapped rclone [...args] {
    if ($env.RCLONE_CONFIG_PASS? | default "" | is-empty) {
        let password_result = (do { pass-cli item view "pass://Personal/rclone/password" --field password } | complete)
        if $password_result.exit_code == 0 {
            $env.RCLONE_CONFIG_PASS = ($password_result.stdout | str trim)
        }
    }
    ^rclone ...$args
}

# Helper: rclone-config
# Runs rclone config and syncs changes to chezmoi
def rclone-config [] {
    rclone config
    print "Syncing rclone config to chezmoi..."
    chezmoi re-add ~/.config/rclone/rclone.conf
    print "Done. Commit with: chezmoi git add -A && chezmoi git commit -m 'Update rclone config'"
}

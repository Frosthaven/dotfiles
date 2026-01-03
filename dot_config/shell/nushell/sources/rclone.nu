# Rclone Integration with Proton Pass
# - Sets RCLONE_CONFIG_PASS from Proton Pass
# - Provides rclone-config helper that syncs to chezmoi

# Set rclone config password from Proton Pass
if (which pass-cli | is-not-empty) {
    let login_check = (do { pass-cli info } | complete)
    if $login_check.exit_code == 0 {
        let password_result = (do { pass-cli view "pass://Personal/rclone/password" } | complete)
        if $password_result.exit_code == 0 {
            $env.RCLONE_CONFIG_PASS = ($password_result.stdout | str trim)
        }
    }
}

# Helper: rclone-config
# Runs rclone config and syncs changes to chezmoi
def rclone-config [] {
    ^rclone config
    print "Syncing rclone config to chezmoi..."
    chezmoi re-add ~/.config/rclone/rclone.conf
    print "Done. Commit with: chezmoi git add -A && chezmoi git commit -m 'Update rclone config'"
}

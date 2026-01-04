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
    chezmoi git -- add dot_config/rclone/private_rclone.conf
    chezmoi git -- commit -m "chore: update rclone config"
    
    # Auto-push if only 1 commit ahead, otherwise warn user
    let ahead_result = (do { chezmoi git -- rev-list --count "@{u}..HEAD" } | complete)
    let ahead_count = if $ahead_result.exit_code == 0 {
        $ahead_result.stdout | str trim | into int
    } else {
        0
    }
    
    if $ahead_count == 1 {
        chezmoi git push
        print "Done. Changes pushed to remote."
    } else {
        print "Done. Multiple unpushed commits detected - run 'chezmoi git push' to sync to remote."
    }
}

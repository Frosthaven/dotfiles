# pass-ssh-unpack wrapper: Syncs chezmoi after running the binary
# See: docs/pass-ssh-unpack.md

# Wrapper for pass-ssh-unpack that syncs rclone config to chezmoi after running
def --wrapped pass-ssh-unpack [...args] {
    # Check if binary exists
    let cargo_bin = ($env.HOME | path join ".cargo/bin/pass-ssh-unpack")
    if (which pass-ssh-unpack-bin | is-empty) and (not ($cargo_bin | path exists)) {
        print "(pass-ssh-unpack) Binary not found. Install with: cargo install pass-ssh-unpack"
        return
    }

    # Always include rclone password path
    let rclone_pass_path = "pass://Personal/rclone/password"
    let full_args = ($args | prepend ["--rclone-password-path", $rclone_pass_path])

    # Run the actual binary directly (preserves TTY for progress bars)
    if (which pass-ssh-unpack-bin | is-not-empty) {
        ^pass-ssh-unpack-bin ...$full_args
    } else {
        ^$cargo_bin ...$full_args
    }

    # Capture exit code after direct execution
    let exit_code = $env.LAST_EXIT_CODE

    # Skip chezmoi sync if command failed or dry-run
    if $exit_code != 0 {
        return
    }

    if ("--dry-run" in $args) {
        return
    }

    # Skip chezmoi sync if chezmoi not available
    if (which chezmoi | is-empty) {
        return
    }

    # Sync rclone config to chezmoi if managed
    let managed_result = (do { chezmoi managed } | complete)
    if $managed_result.exit_code != 0 {
        return
    }

    if not ($managed_result.stdout | str contains "rclone/rclone.conf") {
        return
    }

    # Re-add rclone config
    do { chezmoi re-add ~/.config/rclone/rclone.conf } | complete | ignore

    # Check if there are changes to commit
    let diff_result = (do { chezmoi git -- diff --quiet dot_config/rclone/private_rclone.conf } | complete)
    if $diff_result.exit_code == 0 {
        # No changes
        return
    }

    # Commit changes
    do { chezmoi git -- add dot_config/rclone/private_rclone.conf } | complete | ignore
    do { chezmoi git -- commit -m "chore: update rclone config via pass-ssh-unpack" } | complete | ignore

    # Check how many commits ahead
    let ahead_result = (do { chezmoi git -- rev-list --count "@{u}..HEAD" } | complete)
    let ahead_count = if $ahead_result.exit_code == 0 {
        $ahead_result.stdout | str trim | into int
    } else {
        0
    }

    if $ahead_count == 1 {
        do { chezmoi git push } | complete | ignore
        print "  Synced rclone config to chezmoi (committed and pushed)."
    } else if $ahead_count > 1 {
        print $"  Synced rclone config to chezmoi \(($ahead_count) commits ahead - run 'chezmoi git push' to sync\)."
    } else {
        print "  Synced rclone config to chezmoi."
    }
}

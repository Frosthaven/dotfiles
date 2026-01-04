# pass-ssh-unpack wrapper: Syncs chezmoi after running the binary
# See: docs/pass-ssh-unpack.md

function pass-ssh-unpack
    set -l binary_path ""
    
    # Find the binary
    if command -q pass-ssh-unpack-bin
        set binary_path "pass-ssh-unpack-bin"
    else if test -x "$HOME/.cargo/bin/pass-ssh-unpack"
        set binary_path "$HOME/.cargo/bin/pass-ssh-unpack"
    else
        echo "(pass-ssh-unpack) Binary not found. Install with: cargo install pass-ssh-unpack"
        return 1
    end

    # Run the actual binary
    $binary_path $argv
    set -l exit_code $status

    # Skip chezmoi sync if command failed
    if test $exit_code -ne 0
        return $exit_code
    end

    # Skip chezmoi sync if dry-run
    if contains -- "--dry-run" $argv
        return 0
    end

    # Skip chezmoi sync if chezmoi not available
    if not command -q chezmoi
        return 0
    end

    # Check if rclone config is managed by chezmoi
    if not chezmoi managed 2>/dev/null | grep -q "rclone/rclone.conf"
        return 0
    end

    # Re-add rclone config
    chezmoi re-add ~/.config/rclone/rclone.conf 2>/dev/null

    # Check if there are changes to commit
    if chezmoi git -- diff --quiet dot_config/rclone/private_rclone.conf 2>/dev/null
        # No changes
        return 0
    end

    # Commit changes
    chezmoi git -- add dot_config/rclone/private_rclone.conf 2>/dev/null
    chezmoi git -- commit -m "chore: update rclone config via pass-ssh-unpack" 2>/dev/null

    # Check how many commits ahead
    set -l ahead_count (chezmoi git -- rev-list --count "@{u}..HEAD" 2>/dev/null; or echo "0")

    if test "$ahead_count" = "1"
        chezmoi git push 2>/dev/null
        echo "  Synced rclone config to chezmoi (committed and pushed)."
    else if test "$ahead_count" -gt 1
        echo "  Synced rclone config to chezmoi ($ahead_count commits ahead - run 'chezmoi git push' to sync)."
    else
        echo "  Synced rclone config to chezmoi."
    end
end

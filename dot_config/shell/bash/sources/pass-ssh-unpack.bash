# pass-ssh-unpack wrapper: Syncs chezmoi after running the binary
# See: docs/pass-ssh-unpack.md

pass-ssh-unpack() {
    local binary_path=""
    
    # Find the binary
    if command -v pass-ssh-unpack-bin &>/dev/null; then
        binary_path="pass-ssh-unpack-bin"
    elif [[ -x "$HOME/.cargo/bin/pass-ssh-unpack" ]]; then
        binary_path="$HOME/.cargo/bin/pass-ssh-unpack"
    else
        echo "(pass-ssh-unpack) Binary not found. Install with: cargo install pass-ssh-unpack"
        return 1
    fi

    # Run the actual binary with rclone password path
    "$binary_path" --rclone-password-path "pass://Personal/rclone/password" "$@"
    local exit_code=$?

    # Skip chezmoi sync if command failed
    if [[ $exit_code -ne 0 ]]; then
        return $exit_code
    fi

    # Skip chezmoi sync if dry-run
    for arg in "$@"; do
        if [[ "$arg" == "--dry-run" ]]; then
            return 0
        fi
    done

    # Skip chezmoi sync if chezmoi not available
    if ! command -v chezmoi &>/dev/null; then
        return 0
    fi

    # Check if rclone config is managed by chezmoi
    if ! chezmoi managed 2>/dev/null | grep -q "rclone/rclone.conf"; then
        return 0
    fi

    # Re-add rclone config
    chezmoi re-add ~/.config/rclone/rclone.conf &>/dev/null

    # Check if there are changes to commit
    if chezmoi git -- diff --quiet dot_config/rclone/private_rclone.conf 2>/dev/null; then
        # No changes
        return 0
    fi

    # Commit changes
    chezmoi git -- add dot_config/rclone/private_rclone.conf &>/dev/null
    chezmoi git -- commit -m "chore: update rclone config via pass-ssh-unpack" &>/dev/null

    # Check how many commits ahead
    local ahead_count
    ahead_count=$(chezmoi git -- rev-list --count "@{u}..HEAD" 2>/dev/null || echo "0")

    if [[ "$ahead_count" == "1" ]]; then
        chezmoi git push &>/dev/null
        echo "  Synced rclone config to chezmoi (committed and pushed)."
    elif [[ "$ahead_count" -gt 1 ]]; then
        echo "  Synced rclone config to chezmoi ($ahead_count commits ahead - run 'chezmoi git push' to sync)."
    else
        echo "  Synced rclone config to chezmoi."
    fi
}

# Add /usr/local/bin (system-wide binaries like rclone)
set -gx PATH /usr/local/bin $PATH

# Add $HOME/.local/bin to PATH
set -gx PATH $HOME/.local/bin $PATH

# Add nvim-bob (stable and nightly) to PATH
set -gx PATH $HOME/.local/share/bob/nvim-bin $HOME/.local/share/bob/nightly/bin $PATH

# Add PNPM to PATH
set -gx PNPM_HOME $HOME/.local/share/pnpm
set -gx PATH $PNPM_HOME $PATH

# SSH Agent configuration for Arch-based distros with COSMIC desktop
if command -v pacman &>/dev/null; and test "$XDG_CURRENT_DESKTOP" = "COSMIC"
    set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
    
    # Auto-start service if not running
    if not systemctl --user is-active --quiet ssh-agent.service
        systemctl --user start ssh-agent.service
    end
end

# Load SSH keys from Proton Pass (only if agent is empty)
if command -v pass-cli &>/dev/null
    # Check if keys are already loaded (fast check)
    if ssh-add -l &>/dev/null
        # Keys already loaded, skip pass-cli calls
        set -gx PROTON_PASS_LOGGED_IN "true"
    else
        # No keys loaded, check if logged in to Proton Pass
        if pass-cli info &>/dev/null 2>&1
            set -gx PROTON_PASS_LOGGED_IN "true"
            pass-cli ssh-agent load &>/dev/null
        else
            set -gx PROTON_PASS_LOGGED_IN "false"
            echo "(proton pass) Not logged in. Run 'pass-cli login' to load SSH keys."
        end
    end
end

# Wrapper: rclone with lazy password loading
function rclone --wraps rclone
    if test -z "$RCLONE_CONFIG_PASS"
        set -gx RCLONE_CONFIG_PASS (pass-cli item view "pass://Personal/rclone/password" --field password 2>/dev/null)
    end
    command rclone $argv
end

# Helper: rclone-config - runs rclone config and syncs to chezmoi
function rclone-config
    rclone config
    echo "Syncing rclone config to chezmoi..."
    chezmoi re-add ~/.config/rclone/rclone.conf
    chezmoi git -- add dot_config/rclone/private_rclone.conf
    chezmoi git commit -m "chore: update rclone config"
    
    # Auto-push if only 1 commit ahead, otherwise warn user
    set -l ahead_count (chezmoi git -- rev-list --count @{u}..HEAD 2>/dev/null; or echo "0")
    if test "$ahead_count" = "1"
        chezmoi git push
        echo "Done. Changes pushed to remote."
    else
        echo "Done. Multiple unpushed commits detected - run 'chezmoi git push' to sync to remote."
    end
end

# Starship prompt
starship init fish | source

# eza aliases
alias l='eza --icons=always'
alias ls='eza --icons=always --group --header --group-directories-first'
alias ll='eza --icons=always --group --header --group-directories-first --long --git'
alias lg='eza --icons=always --group --header --group-directories-first --long --git --git-ignore'
alias le='eza --icons=always --group --header --group-directories-first --long --extended'
alias lt='eza --icons=always --group --header --group-directories-first --tree --level level'
alias lc='eza --icons=always --group --header --group-directories-first --across'
alias lo='eza --icons=always --group --header --group-directories-first --oneline'
alias la='eza --icons=always --all'
alias lsa='eza --icons=always --group --header --group-directories-first --all'
alias lla='eza --icons=always --group --header --group-directories-first --all --long --git'
alias lga='eza --icons=always --group --header --group-directories-first --all --long --git --git-ignore'

# Neovim aliases
alias vim='nvim'
alias vi='nvim'

# Zoxide
zoxide init fish | source
alias cd='z'  # replace cd with zoxide

# fzf file search helper (sf)
function sf
    set file (fzf --preview "bat --color=always {}" \
                  --preview-window=right:50%:wrap \
                  --height 50% \
                  --border \
                  --prompt="search files: " \
                  --query="$argv")
    if test -n "$file"
        nvim "$file"  # replace with preferred editor if desired
    end
end

# Automatic Nushell (optional)
# if not set -q NU; and test -x "$HOME/.cargo/bin/nu"
#     exec "$HOME/.cargo/bin/nu"
# end

# Add Cargo to PATH
if test -d "$HOME/.cargo/bin"
    set -gx PATH $HOME/.cargo/bin $PATH
end

# Source additional functions
source "$HOME/.config/shell/fish/sources/pass-ssh-unpack.fish"
source "$HOME/.config/shell/fish/sources/system-update.fish"
